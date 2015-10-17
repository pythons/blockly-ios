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
Class representing an input (value, statement, or dummy).
*/
@objc(BKYInput)
public class Input : NSObject {
  // MARK: - Enum - InputType

  /** Represents types of inputs. */
  @objc
  public enum BKYInputType: Int {
    case Value = 0, Statement, Dummy

    private static let stringMapping = [
      Value: "input_value",
      Statement: "input_statement",
      Dummy: "input_dummy",
    ]

    public var stringValue : String {
      return BKYInputType.stringMapping[self]!
    }

    internal init?(string: String) {
      guard let value = BKYInputType.stringMapping.bky_anyKeyForValue(string) else {
        return nil
      }
      self = value
    }
  }
  public typealias InputType = BKYInputType

  // MARK: - Enum - InputAlignment

  /** Represents valid alignments of a connection's fields. */
  @objc
  public enum BKYInputAlignment: Int {
    case Left = -1, Centre = 0, Right = 1

    private static let stringMapping = [
      Left: "LEFT",
      Centre: "CENTRE",
      Right: "RIGHT",
    ]

    public var stringValue : String {
      return BKYInputAlignment.stringMapping[self]!
    }

    internal init?(string: String) {
      guard let value = BKYInputAlignment.stringMapping.bky_anyKeyForValue(string) else {
        return nil
      }
      self = value
    }
  }
  public typealias Alignment = BKYInputAlignment

  // MARK: - Properties

  public let type: BKYInputType
  public let name: String
  public weak var sourceBlock: Block! {
    didSet {
      self.connection?.sourceBlock = sourceBlock
    }
  }
  public private(set) var connection: Connection?
  /// The block that is connected to this input, if it exists.
  public var connectedBlock: Block? {
    return connection?.targetConnection?.sourceBlock
  }

  public var visible: Bool = true
  public var alignment: BKYInputAlignment = BKYInputAlignment.Left
  public private(set) var fields: [Field] = []

  /// The layout used for rendering this input
  public private(set) var layout: InputLayout?

  // MARK: - Initializers

  public init(type: InputType, name: String, workspace: Workspace) {
    self.name = name
    self.type = type

    super.init()

    if (type == .Value) {
      self.connection = Connection(type: .InputValue, sourceInput: self)
    } else if (type == .Statement) {
      self.connection = Connection(type: .NextStatement, sourceInput: self)
    }

    do {
      self.layout = try workspace.layoutFactory?.layoutForInput(self, workspace: workspace)
    } catch let error as NSError {
      bky_assertionFailure("Could not initialize the layout: \(error)")
    }
  }

  // MARK: - Public


  /**
  Appends a field to `self.fields[]`.

  - Parameter field: The field to append.
  */
  public func appendField(field: Field) {
    fields.append(field)

    // Append the field's layout to this input layout
    if field.layout != nil {
      layout?.appendFieldLayout(field.layout!)
    }
  }

  /**
  Appends a given list of fields to the end of `self.fields[]`.

  - Parameter fields: The fields to append.
  */
  public func appendFields(fields: [Field]) {
    for field in fields {
      appendField(field)
    }
  }
}
