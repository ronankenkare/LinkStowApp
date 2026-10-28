"""Verify authored configuration/resource relationships without Xcode or MCP."""

import hashlib
import json
from pathlib import Path
import plistlib
import re
import xml.etree.ElementTree as ET


def check_configuration(root, elements, native_edges):
    errors = []
    index_path = root / "docs/configuration-traces.json"
    try:
        index = json.loads(index_path.read_text())
        if index.get("format") != "linkstow-configuration-traces" or index.get("version") != 1:
            return ["Unsupported configuration trace format"]
        artifacts = {a["key"]: a for a in index["artifacts"]}
        for artifact in artifacts.values():
            saved = elements.get(artifact["id"], {})
            expected = {
                "path": artifact["path"], "symbol": artifact["symbol"],
                "startLine": artifact["start_line"], "endLine": artifact["end_line"],
                "contentHash": artifact["sha256"],
            }
            if saved.get("kind") != "code-artifact" or saved.get("properties") != expected:
                errors.append(f"Configuration anchor differs from saved model: {artifact['key']}")
        for edge in index["edges"]:
            if (edge["kind"], edge["source_id"], edge["target_id"]) not in native_edges:
                errors.append(f"Missing configuration/resource trace: {edge['role']}")

        # Inventory independently of the registered elements: a new asset
        # definition or an omitted critical build input must not vanish from
        # coverage merely because it has no artifact yet.
        catalog = root / "LinkStow/Assets.xcassets"
        current_assets = {
            p.relative_to(root).as_posix() for p in catalog.rglob("Contents.json")
            if p.parent.suffix in {".colorset", ".imageset", ".appiconset"}
        }
        recorded_assets = {a["path"] for a in index["assets"]}
        if current_assets != recorded_assets:
            errors.append("Asset trace inventory is stale; review added/removed asset definitions")
        required_inputs = {
            "LinkStow-Info.plist", "LinkStow/LinkStow.entitlements",
            "LinkStow/App/LaunchScreen.storyboard", "LinkStow.xctestplan",
            "LinkStow.xcodeproj/project.pbxproj",
            "LinkStow.xcodeproj/xcshareddata/xcschemes/LinkStow.xcscheme",
            "LinkStow.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved",
        }
        if not required_inputs.issubset({a["path"] for a in artifacts.values()}):
            errors.append("Configuration trace inventory omits a required build/resource input")

        for asset in index["assets"]:
            data = json.loads((root / asset["path"]).read_text())
            if asset["status"] not in {"active", "dormant", "unreferenced", "documentation-only", "configured-empty"}:
                errors.append(f"Unknown asset state: {asset['name']}")
            expected_payloads = {
                (Path(asset["path"]).parent / item["filename"]).as_posix()
                for item in data.get("images", []) if item.get("filename")
            }
            if expected_payloads != {p["path"] for p in asset["payloads"]}:
                errors.append(f"Asset image manifest changed: {asset['name']}")
            for payload in asset["payloads"]:
                path = (root / payload["path"]).resolve()
                if not path.is_relative_to(root.resolve()):
                    errors.append(f"Asset payload escapes repository: {asset['name']}")
                elif not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != payload["sha256"]:
                    errors.append(f"Asset payload drift: {payload['path']}")
            if asset["status"] == "configured-empty" and any(c.get("color") for c in data.get("colors", [])):
                errors.append(f"Empty-color classification needs review: {asset['name']}")

        for reference in index["references"]:
            artifact = artifacts[reference["source_key"]]
            path = (root / artifact["path"]).resolve()
            if not path.is_relative_to(root.resolve()):
                errors.append("Resource reference escapes repository")
                continue
            lines = path.read_text().splitlines()
            fragment = "\n".join(lines[artifact["start_line"] - 1:artifact["end_line"]])
            if reference["expression"] not in fragment:
                errors.append(f"Resource reference is outside its source anchor: {reference['source_key']}")

        plist = plistlib.loads((root / "LinkStow-Info.plist").read_bytes())
        entitlements = plistlib.loads((root / "LinkStow/LinkStow.entitlements").read_bytes())
        if plist or entitlements:
            errors.append("Empty plist/signing-input classification needs review")
        project = (root / "LinkStow.xcodeproj/project.pbxproj").read_text()
        if "UILaunchStoryboardName" in project or any(k.startswith("UILaunchStoryboardName") for k in plist):
            errors.append("Storyboard selection changed; review its inactive classification")
        if not re.search(r"INFOPLIST_KEY_UILaunchScreen_Generation\s*=\s*YES", project):
            errors.append("Generated launch-screen configuration changed")
        storyboard = ET.parse(root / "LinkStow/App/LaunchScreen.storyboard")
        known_names = {a["name"] for a in index["assets"]}
        missing = {node.get("image") for node in storyboard.iter() if node.get("image") and node.get("image") not in known_names}
        if missing != set(index["storyboard"]["missing_images"]):
            errors.append("Storyboard resource findings changed; review missing/resolved images")
        if index["storyboard"]["status"] != "not-selected-by-launch-settings":
            errors.append("Storyboard must retain its verified configuration status")

        # XML/JSON parsing checks inputs independently of source fingerprints.
        ET.parse(root / "LinkStow.xcodeproj/xcshareddata/xcschemes/LinkStow.xcscheme")
        plan = json.loads((root / "LinkStow.xctestplan").read_text())
        names = sorted(t["target"]["name"] for t in plan["testTargets"])
        if names != sorted(index["test_targets"]):
            errors.append("Test-plan target inventory changed")
        lock = json.loads((root / "LinkStow.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved").read_text())
        pin = next(p for p in lock["pins"] if p["identity"] == "swiftsoup")
        if pin["state"] != index["swiftsoup_pin"]:
            errors.append("SwiftSoup pin changed; review dependency traces")
    except (OSError, ValueError, KeyError, TypeError, StopIteration, ET.ParseError, plistlib.InvalidFileException) as error:
        errors.append(f"{index_path}: {error}")
    return errors
