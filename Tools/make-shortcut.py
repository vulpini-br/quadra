#!/usr/bin/env python3
"""Writes the "Quadra" shortcut used by the Mac App Store version (unsigned).

It receives JSON text such as {"app": "Safari", "x": 0, "y": 25, "w": 960, "h": 1055}
(points, origin at the top left of the main display), finds the app's front window and
resizes and moves it there. build.sh --appstore signs it with `shortcuts sign` and puts
it inside the app, which offers it to the user in its welcome window.

Usage: python3 Tools/make-shortcut.py OUTPUT.shortcut
"""
import plistlib
import sys
import uuid


def new_id():
    return str(uuid.uuid4()).upper()


def output_of(action_id, name):
    """A reference to another action's result."""
    return {"Value": {"Type": "ActionOutput", "OutputUUID": action_id, "OutputName": name},
            "WFSerializationType": "WFTextTokenAttachment"}


def text_with(action_id, name):
    """Text made of another action's result (for a filter value)."""
    return {"Value": {"string": "￼",
                      "attachmentsByRange": {"{0, 1}": {"Type": "ActionOutput", "OutputUUID": action_id,
                                                        "OutputName": name}}},
            "WFSerializationType": "WFTextTokenString"}


def action(identifier, **parameters):
    return {"WFWorkflowActionIdentifier": identifier, "WFWorkflowActionParameters": parameters}


dictionary = new_id()
values = {key: new_id() for key in ["app", "x", "y", "w", "h"]}
window = new_id()
value = lambda key: output_of(values[key], "Dictionary Value")

actions = [action("is.workflow.actions.detect.dictionary", UUID=dictionary,
                  WFInput={"Value": {"Type": "ExtensionInput"}, "WFSerializationType": "WFTextTokenAttachment"})]
for key, key_id in values.items():
    actions.append(action("is.workflow.actions.getvalueforkey", UUID=key_id, WFDictionaryKey=key,
                          WFGetDictionaryValueType="Value", WFInput=output_of(dictionary, "Dictionary")))
actions += [
    # The app's front window.
    action("is.workflow.actions.filter.windows", UUID=window,
           WFContentItemSortProperty="Window Index", WFContentItemSortOrder="Smallest First",
           WFContentItemLimitEnabled=True, WFContentItemLimitNumber=1,
           WFContentItemFilter={"Value": {"WFActionParameterFilterPrefix": 1, "WFContentPredicateBoundedDate": False,
                                          "WFActionParameterFilterTemplates": [
                                              {"Property": "App Name", "Operator": 4, "Removable": True,
                                               "VariableOverrides": {},
                                               "Values": {"String": text_with(values["app"], "Dictionary Value"),
                                                          "Unit": 4}}]},
                                "WFSerializationType": "WFContentPredicateTableTemplate"}),
    # Size, position, and size again: some apps limit the size by the space left at the old position.
    action("is.workflow.actions.resizewindow", WFWindow=output_of(window, "Windows"), WFConfiguration="Dimensions",
           WFWidth=value("w"), WFHeight=value("h"), WFBringToFront=False),
    action("is.workflow.actions.movewindow", WFWindow=output_of(window, "Windows"), WFPosition="Coordinates",
           WFXCoordinate=value("x"), WFYCoordinate=value("y"), WFBringToFront=False),
    action("is.workflow.actions.resizewindow", WFWindow=output_of(window, "Windows"), WFConfiguration="Dimensions",
           WFWidth=value("w"), WFHeight=value("h"), WFBringToFront=False),
]

workflow = {
    "WFWorkflowClientVersion": "2700.0.0",
    "WFWorkflowMinimumClientVersion": 900,
    "WFWorkflowMinimumClientVersionString": "900",
    "WFWorkflowIcon": {"WFWorkflowIconStartColor": 463140863, "WFWorkflowIconGlyphNumber": 59511},
    "WFWorkflowImportQuestions": [],
    "WFWorkflowTypes": [],
    "WFWorkflowInputContentItemClasses": ["WFStringContentItem", "WFDictionaryContentItem"],
    "WFWorkflowOutputContentItemClasses": [],
    "WFWorkflowActions": actions,
}

with open(sys.argv[1], "wb") as f:
    plistlib.dump(workflow, f, fmt=plistlib.FMT_BINARY)
