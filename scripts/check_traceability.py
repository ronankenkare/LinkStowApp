#!/usr/bin/env python3
"""Check saved plus-c references, source hashes and need-to-code decomposition.

Run from any directory. Uses only the Python standard library and never contacts
the MCP server. This checks trace integrity, not application behavior.
"""

import hashlib
import json
from pathlib import Path
import sys

from check_configuration_traces import check_configuration


ROOT = Path(__file__).resolve().parents[1]
TRACE_KINDS = {"refines", "realizes", "represents", "satisfies", "implements"}


def check(root=ROOT):
    errors = []
    elements = {}
    views = []
    parts = [root / "project.plc", *sorted((root / "diagrams").glob("*.plc"))]
    for path in parts:
        try:
            data = json.loads(path.read_text())
            if data.get("format") != "plus-c-project-part" or data.get("version") != 1:
                errors.append(f"{path.name}: unsupported plus-c format")
            for element in data["project"]["elements"]:
                previous = elements.get(element["id"])
                # Shared elements must have the same semantics in every view.
                fields = ("kind", "name", "documentation", "properties", "ownerId")
                if previous and any(previous.get(k) != element.get(k) for k in fields):
                    errors.append(f"Conflicting shared element: {element['id']}")
                elements[element["id"]] = element
            views.extend(data["project"]["views"])
        except (OSError, ValueError, KeyError, TypeError) as error:
            errors.append(f"{path}: {error}")

    for view in views:
        for field in ("diagramId", "elementId"):
            if view.get(field) not in elements:
                errors.append(f"Broken view {view.get('id')}: {field}")
    edges = set()
    for element in elements.values():
        for field in ("sourceId", "targetId"):
            if field in element and element[field] not in elements:
                errors.append(f"Broken {field}: {element['id']}")
        if element["kind"] in TRACE_KINDS:
            edges.add((element["kind"], element.get("sourceId"), element.get("targetId")))

    artifacts = [e for e in elements.values() if e["kind"] == "code-artifact"]
    # Element-level coverage alone can look complete even when an entire file
    # has never been registered. Inventory application and test Swift sources
    # independently so adding a new file cannot silently bypass the check.
    traced_paths = {
        e["properties"]["path"] for e in artifacts
        if any(e["id"] in (source, target) for _, source, target in edges)
    }
    for folder in ("LinkStow", "LinkStowTests"):
        for path in sorted((root / folder).rglob("*.swift")):
            relative = path.relative_to(root).as_posix()
            if relative not in traced_paths:
                errors.append(f"Untraced Swift file: {relative}")
    for artifact in artifacts:
        props = artifact["properties"]
        path = root / props["path"]
        try:
            if not path.resolve().is_relative_to(root.resolve()):
                raise ValueError("source path escapes repository")
            content = path.read_bytes()
            if hashlib.sha256(content).hexdigest() != props.get("contentHash"):
                errors.append(f"Source drift: {props['path']} (review diagrams before re-registering)")
            count = len(content.decode().splitlines())
            if not 1 <= props.get("startLine", 0) <= props.get("endLine", 0) <= count:
                errors.append(f"Invalid source range: {props['path']}")
        except (OSError, ValueError) as error:
            errors.append(f"{props['path']}: {error}")

    def sources(kind, target):
        return {source for edge_kind, source, end in edges if edge_kind == kind and end == target}

    requirements = {
        e["properties"]["key"]: e["id"] for e in elements.values()
        if e["kind"] == "document-requirement"
    }
    needs = {key: value for key, value in requirements.items() if key.startswith("NEED-")}
    reqs = {key: value for key, value in requirements.items() if key.startswith("REQ-")}
    systems = {e["id"] for e in elements.values() if e["kind"] == "system-of-interest"}
    subsystems = {
        e["id"] for e in elements.values()
        if e["kind"] == "class" and e["properties"].get("stereotype") == "logical subsystem"
    }
    implementation = {
        e["id"] for e in artifacts if e["properties"]["path"].startswith("LinkStow/")
    }
    for key, need in needs.items():
        if not sources("refines", need).intersection(reqs.values()):
            errors.append(f"{key}: no refining system requirement")
    for key, req in reqs.items():
        if not any(("refines", req, need) in edges for need in needs.values()):
            errors.append(f"{key}: no stakeholder need")
        # Require each level explicitly: requirement <- system <- subsystem
        # <- source classifier <- implementation artifact. Evidence links cannot
        # stand in for an allocation or conceal a missing decomposition level.
        chains = [
            (system, subsystem, classifier, artifact)
            for system in systems.intersection(sources("satisfies", req))
            for subsystem in subsystems.intersection(sources("refines", system))
            if ("satisfies", subsystem, req) in edges
            for classifier in sources("realizes", subsystem)
            for artifact in implementation.intersection(sources("implements", classifier))
        ]
        if not chains:
            errors.append(f"{key}: missing complete system/subsystem/code chain")
    titles = {e["name"] for e in elements.values() if e["kind"] == "diagram"}
    for category in ("System context", "Component architecture", "Save-link flow",
                     "Data model", "Main state machine", "Hidden-link security"):
        if not any(title.endswith(category) for title in titles):
            errors.append(f"Missing diagram category: {category}")
    if not needs or not reqs or not implementation:
        errors.append("Stakeholder needs, system requirements and source artifacts are required")

    # This index records authored code-to-code mappings. A diagram or a generic
    # file dependency cannot stand in for the exact call-site/definition edge.
    connections_path = root / "docs" / "code-connections.json"
    try:
        index = json.loads(connections_path.read_text())
        if index.get("format") != "linkstow-code-connections" or index.get("version") != 1:
            errors.append("Unsupported code-connections format")
        connections = index["connections"]
        if not connections:
            errors.append("Code-to-code connections are required")
        seen = set()
        for connection in connections:
            key = connection["id"]
            if key in seen:
                errors.append(f"Duplicate code connection: {key}")
            seen.add(key)
            for endpoint in ("call_site", "callee"):
                part = connection[endpoint]
                artifact = elements.get(part["id"], {})
                expected = {
                    "path": part["path"], "symbol": part["symbol"],
                    "startLine": part["start_line"], "endLine": part["end_line"],
                    "contentHash": part["sha256"],
                }
                if artifact.get("kind") != "code-artifact" or artifact.get("properties") != expected:
                    errors.append(f"{key}: {endpoint} differs from saved Plus+C artifact")
            edge = (connection["native_kind"], connection["call_site"]["id"], connection["callee"]["id"])
            if edge not in edges:
                errors.append(f"{key}: missing native call-site-to-definition trace")
            site = connection["call_site"]
            path = (root / site["path"]).resolve()
            if not path.is_relative_to(root.resolve()):
                errors.append(f"{key}: call-site path escapes repository")
                continue
            fragment = "\n".join(path.read_text().splitlines()[site["start_line"] - 1:site["end_line"]])
            if connection["expression"] not in fragment:
                errors.append(f"{key}: call expression is outside its registered range")
    except (OSError, ValueError, KeyError, TypeError) as error:
        errors.append(f"{connections_path}: {error}")

    readme_index_path = root / "docs" / "readme-traces.json"
    try:
        index = json.loads(readme_index_path.read_text())
        if index.get("format") != "linkstow-readme-traces" or index.get("version") != 1:
            errors.append("Unsupported README trace format")
        readme_hash = hashlib.sha256((root / "README.md").read_bytes()).hexdigest()
        if index["readme"]["sha256"] != readme_hash:
            errors.append("README trace index is stale; review and re-register its anchors")
        for part in index["parts"]:
            artifact = elements.get(part["id"], {})
            props = artifact.get("properties", {})
            expected = {
                "path": "README.md", "symbol": part["symbol"],
                "startLine": part["start_line"], "endLine": part["end_line"],
                "contentHash": readme_hash,
            }
            if artifact.get("kind") != "code-artifact" or props != expected:
                errors.append(f"README anchor differs from saved model: {part['key']}")
        for edge in index["edges"]:
            if (edge["kind"], edge["source_id"], edge["target_id"]) not in edges:
                errors.append(f"Missing README trace: {edge['role']} ({edge['source_id']} -> {edge['target_id']})")
        bridges = index["diagram_bridges"]
        diagram_ids = {e["id"] for e in elements.values() if e["kind"] == "diagram"}
        if {b["diagram_id"] for b in bridges} != diagram_ids:
            errors.append("Every saved diagram must have a README bridge")
        for bridge in bridges:
            start = bridge["diagram_id"]
            middle = bridge["readme_part_id"]
            if ("represents", start, middle) not in edges:
                errors.append(f"Missing diagram-to-README trace: {start}")
            if not bridge["source_ids"]:
                errors.append(f"README bridge has no implementation evidence: {start}")
            for target in bridge["source_ids"]:
                if ("represents", middle, target) not in edges:
                    errors.append(f"Missing README-to-code trace: {start} -> {target}")
                artifact = elements.get(target, {})
                if artifact.get("kind") != "code-artifact" or not artifact.get("properties", {}).get("path", "").startswith("LinkStow/"):
                    errors.append(f"README bridge does not reach app source: {start} -> {target}")
    except (OSError, ValueError, KeyError, TypeError) as error:
        errors.append(f"{readme_index_path}: {error}")
    errors.extend(check_configuration(root, elements, edges))
    return errors, (len(titles), len(needs), len(reqs), len(artifacts), len(edges))


if __name__ == "__main__":
    issues, counts = check()
    for issue in issues:
        print(f"ERROR: {issue}", file=sys.stderr)
    if issues:
        sys.exit(1)
    print("Traceability OK: %d diagrams, %d needs, %d requirements, %d source artifacts, %d traces." % counts)
