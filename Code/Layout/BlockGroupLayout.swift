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
Stores information on how to render and position a group of sequential `Block` objects (ie. those
that are connecting via previous/next connections).
*/
@objc(BKYBlockGroupLayout)
public class BlockGroupLayout: Layout {
  // MARK: - Properties

  /*
  A list of sequential block layouts that belong to this group. While this class doesn't enforce
  it, the following should hold true:

  1) When `i < blockLayouts.count - 1`:

  `blockLayouts[i].block.nextBlock = blockLayouts[i + 1].block`

  2) When `i >= 1`:

  `blockLayouts[i].block.previousBlock = blockLayouts[i - 1].block`
  */
  public private(set) var blockLayouts = [BlockLayout]()

  // MARK: - Initializers

  public override init(workspaceLayout: WorkspaceLayout) {
    super.init(workspaceLayout: workspaceLayout)
  }

  // MARK: - Super

  public override var childLayouts: [Layout] {
    return blockLayouts
  }

  public override func layoutChildren() {
    var yOffset: CGFloat = 0
    var size = WorkspaceSizeZero

    // Update relative position/size of inputs
    for blockLayout in blockLayouts {
      blockLayout.layoutChildren()

      blockLayout.relativePosition.x = 0
      blockLayout.relativePosition.y = yOffset

      // Blocks are technically overlapping, so the actual amount that the next block is offset by
      // must take into account the size of the notch height
      yOffset += blockLayout.totalSize.height - BlockLayout.sharedConfig.notchHeight

      size = LayoutHelper.sizeThatFitsLayout(blockLayout, fromInitialSize: size)
    }

    // Update the size required for this block
    self.contentSize = size
  }

  // MARK: - Public

  /**
  Appends a blockLayout to `self.blockLayouts` and sets its `parentLayout` to this instance.

  - Parameter blockLayout: The `BlockLayout` to append.
  */
  public func appendBlockLayout(blockLayout: BlockLayout) {
    blockLayout.parentLayout = self
    blockLayouts.append(blockLayout)
  }

  /**
  Appends all blockLayouts to `self.blockLayouts` and sets their `parentLayout` to this instance.

  - Parameter blockLayouts: The list of `BlockLayout` instances to append.
  */
  public func appendBlockLayouts(blockLayouts: [BlockLayout]) {
    for blockLayout in blockLayouts {
      appendBlockLayout(blockLayout)
    }
  }

  /**
  Removes a given block layout and all subsequent layouts from `blockLayouts`, and returns them in
  an array.

  - Parameter blockLayout: The given block layout to find and remove.
  - Returns: The list of block layouts that were removed, starting from the given block layout. If
  the given block layout could not be found, it is still returned as a single-element list.
  */
  public func removeAllStartingFromBlockLayout(blockLayout: BlockLayout) -> [BlockLayout] {
    var removedElements = [BlockLayout]()

    if let index = blockLayouts.indexOf(blockLayout) {
      while (index < blockLayouts.count) {
        let removedLayout = blockLayouts.removeAtIndex(index)
        removedLayout.parentLayout = nil
        removedElements.append(removedLayout)
      }
    } else {
      // Always return the given block layout, even it's not found
      removedElements.append(blockLayout)
      blockLayout.parentLayout = nil
    }

    return removedElements
  }

  /**
  If this instance's `parentLayout` is an instance of `WorkspaceLayout`, this method changes
  `relativePosition` to the position. If not, this method does nothing.

  - Parameter position: The relative position within its parent's Workspace layout, specified as a
  Workspace coordinate system point.
  */
  public func moveToWorkspacePosition(position: WorkspacePoint) {
    if self.parentLayout is WorkspaceLayout {
      self.relativePosition = position
      self.refreshViewBoundsForTree()
    }
  }
}
