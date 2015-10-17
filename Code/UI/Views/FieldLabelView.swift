/*
* Copyright 2015 Google Inc. All Rights Reserved.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Foundation

/**
View for rendering a `FieldLabelLayout`.
*/
@objc(BKYFieldLabelView)
public class FieldLabelView: UILabel {
  // MARK: - Properties

  /// Layout object to render
  public var layout: FieldLabelLayout? {
    didSet {
      oldValue?.delegate = nil
      layout?.delegate = self
      refreshView()
    }
  }

  // MARK: - Initializers

  public required init() {
    super.init(frame: CGRectZero)
  }

  public required init?(coder aDecoder: NSCoder) {
    bky_assertionFailure("Called unsupported initializer")
    super.init(coder: aDecoder)
  }

  // MARK: - Public

  /**
  Refreshes the view based on the current layout.
  */
  public func refreshView() {
    guard let layout = self.layout else {
      ViewManager.sharedInstance.recycleView(self)
      return
    }

    refreshPosition()

    self.text = layout.fieldLabel.text

    // TODO:(vicng) This is only for debugging. Remove this once block rendering is in a "good"
    // state.
    self.backgroundColor = UIColor.redColor()

    // TODO:(vicng) Standardize this font
    self.font = UIFont.systemFontOfSize(14 * layout.workspaceLayout.scale)
  }

  /**
  Refreshes `frame` based on the current layout.
  */
  private func refreshPosition() {
    guard let layout = self.layout else {
      ViewManager.sharedInstance.recycleView(self)
      return
    }

    self.frame = layout.viewFrame
  }
}

// MARK: - LayoutDelegate implementation

extension FieldLabelView: LayoutDelegate {
  public func layoutDisplayChanged(layout: Layout) {
    refreshView()
  }

  public func layoutPositionChanged(layout: Layout) {
    refreshPosition()
  }
}

// MARK: - FieldLayoutMeasurer implementation

extension FieldLabelView: FieldLayoutMeasurer {
  public static func measureLayout(layout: FieldLayout, scale: CGFloat) -> CGSize {
    guard let fieldLayout = layout as? FieldLabelLayout else {
      bky_assertionFailure("Cannot measure layout of type [\(layout.dynamicType.description)]. " +
        "Expected type [FieldLabelLayout].")
      return CGSizeZero
    }
    // TODO:(vicng) Return different values based on the scale
    // TODO:(vicng) Use a standardized font size that can be configurable for the project
    return fieldLayout.fieldLabel.text.bky_singleLineSizeForFont(
      UIFont.systemFontOfSize(14 * scale))
  }
}

// MARK: - Recyclable implementation

extension FieldLabelView: Recyclable {
  public func recycle() {
    self.layout = nil
    self.frame = CGRectZero
    self.text = ""
  }
}
