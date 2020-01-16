// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: mempool_status.proto
//
// For information on using the generated types, please see the documenation:
//   https://github.com/apple/swift-protobuf/

// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that your are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

enum MempoolStatus_MempoolAddTransactionStatusCode: SwiftProtobuf.Enum {
  typealias RawValue = Int

  /// Transaction was sent to Mempool
  case valid // = 0

  /// The sender does not have enough balance for the transaction.
  case insufficientBalance // = 1

  /// Sequence number is old, etc.
  case invalidSeqNumber // = 2

  /// Mempool is full (reached max global capacity)
  case mempoolIsFull // = 3

  /// Account reached max capacity per account
  case tooManyTransactions // = 4

  /// Invalid update. Only gas price increase is allowed
  case invalidUpdate // = 5
  case UNRECOGNIZED(Int)

  init() {
    self = .valid
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .valid
    case 1: self = .insufficientBalance
    case 2: self = .invalidSeqNumber
    case 3: self = .mempoolIsFull
    case 4: self = .tooManyTransactions
    case 5: self = .invalidUpdate
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .valid: return 0
    case .insufficientBalance: return 1
    case .invalidSeqNumber: return 2
    case .mempoolIsFull: return 3
    case .tooManyTransactions: return 4
    case .invalidUpdate: return 5
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension MempoolStatus_MempoolAddTransactionStatusCode: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [MempoolStatus_MempoolAddTransactionStatusCode] = [
    .valid,
    .insufficientBalance,
    .invalidSeqNumber,
    .mempoolIsFull,
    .tooManyTransactions,
    .invalidUpdate,
  ]
}

#endif  // swift(>=4.2)

struct MempoolStatus_MempoolAddTransactionStatus {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var code: MempoolStatus_MempoolAddTransactionStatusCode = .valid

  var message: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "mempool_status"

extension MempoolStatus_MempoolAddTransactionStatusCode: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "Valid"),
    1: .same(proto: "InsufficientBalance"),
    2: .same(proto: "InvalidSeqNumber"),
    3: .same(proto: "MempoolIsFull"),
    4: .same(proto: "TooManyTransactions"),
    5: .same(proto: "InvalidUpdate"),
  ]
}

extension MempoolStatus_MempoolAddTransactionStatus: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".MempoolAddTransactionStatus"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "code"),
    2: .same(proto: "message"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularEnumField(value: &self.code)
      case 2: try decoder.decodeSingularStringField(value: &self.message)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.code != .valid {
      try visitor.visitSingularEnumField(value: self.code, fieldNumber: 1)
    }
    if !self.message.isEmpty {
      try visitor.visitSingularStringField(value: self.message, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: MempoolStatus_MempoolAddTransactionStatus, rhs: MempoolStatus_MempoolAddTransactionStatus) -> Bool {
    if lhs.code != rhs.code {return false}
    if lhs.message != rhs.message {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
