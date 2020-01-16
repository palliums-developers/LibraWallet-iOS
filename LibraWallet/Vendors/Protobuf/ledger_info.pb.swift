// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: ledger_info.proto
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

//// Even though we don't always need all hashes, we pass them in and return them
//// always so that we keep them in sync on the client and don't make the client
//// worry about which one(s) to pass in which cases
////
//// This structure serves a dual purpose.
////
//// First, if this structure is signed by 2f+1 validators it signifies the state
//// of the ledger at version `version` -- it contains the transaction
//// accumulator at that version which commits to all historical transactions.
//// This structure may be expanded to include other information that is derived
//// from that accumulator (e.g. the current time according to the time contract)
//// to reduce the number of proofs a client must get.
////
//// Second, the structure contains a `consensus_data_hash` value. This is the
//// hash of an internal data structure that represents a block that is voted on
//// by consensus.
////
//// Combining these two concepts when the consensus algorithm votes on a block B
//// it votes for a LedgerInfo with the `version` being the latest version that
//// will be committed if B gets 2f+1 votes. It sets `consensus_data_hash` to
//// represent B so that if those 2f+1 votes are gathered, the block is valid to
//// commit
struct Types_LedgerInfo {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Current latest version of the system
  var version: UInt64 {
    get {return _storage._version}
    set {_uniqueStorage()._version = newValue}
  }

  /// Root hash of transaction accumulator at this version
  var transactionAccumulatorHash: Data {
    get {return _storage._transactionAccumulatorHash}
    set {_uniqueStorage()._transactionAccumulatorHash = newValue}
  }

  /// Hash of consensus-specific data that is opaque to all parts of the system
  /// other than consensus.  This is needed to verify signatures because
  /// consensus signing includes this hash
  var consensusDataHash: Data {
    get {return _storage._consensusDataHash}
    set {_uniqueStorage()._consensusDataHash = newValue}
  }

  /// The block id of the last committed block corresponding to this ledger info.
  /// This field is not particularly interesting to the clients, but can be used
  /// by the validators for synchronization.
  var consensusBlockID: Data {
    get {return _storage._consensusBlockID}
    set {_uniqueStorage()._consensusBlockID = newValue}
  }

  /// Epoch number corresponds to the set of validators that are active for this
  /// ledger info. The main motivation for keeping the epoch number in the
  /// LedgerInfo is to ensure that the client has enough information to verify
  /// that the signatures for this info are coming from the validators that
  /// indeed form a quorum. Without epoch number a potential attack could reuse
  /// the signatures from the validators in one epoch in order to sign the wrong
  /// info belonging to another epoch, in which these validators do not form a
  /// quorum. The very first epoch number is 0.
  var epoch: UInt64 {
    get {return _storage._epoch}
    set {_uniqueStorage()._epoch = newValue}
  }

  /// Consensus protocol operates in rounds: the number corresponds to the proposal round of a
  /// given commit. Not relevant to the clients,
  /// but can be used by the validators for synchronization.
  var round: UInt64 {
    get {return _storage._round}
    set {_uniqueStorage()._round = newValue}
  }

  /// Timestamp that represents the microseconds since the epoch (unix time) that is
  /// generated by the proposer of the block.  This is strictly increasing with every block.
  /// If a client reads a timestamp > the one they specified for transaction expiration time,
  /// they can be certain that their transaction will never be included in a block in the future
  /// (assuming that their transaction has not yet been included)
  var timestampUsecs: UInt64 {
    get {return _storage._timestampUsecs}
    set {_uniqueStorage()._timestampUsecs = newValue}
  }

  /// An optional field with the validator set for the next epoch in case it's the last
  /// ledger info in the current epoch.
  var nextValidatorSet: Types_ValidatorSet {
    get {return _storage._nextValidatorSet ?? Types_ValidatorSet()}
    set {_uniqueStorage()._nextValidatorSet = newValue}
  }
  /// Returns true if `nextValidatorSet` has been explicitly set.
  var hasNextValidatorSet: Bool {return _storage._nextValidatorSet != nil}
  /// Clears the value of `nextValidatorSet`. Subsequent reads from it will return its default value.
  mutating func clearNextValidatorSet() {_uniqueStorage()._nextValidatorSet = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

//// The validator node returns this structure which includes signatures
//// from each validator to confirm the state.  The client needs to only pass
//// back the LedgerInfo element since the validator node doesn't need to know
//// the signatures again when the client performs a query, those are only there
//// for the client to be able to verify the state
struct Types_LedgerInfoWithSignatures {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Signatures of the root node from each validator
  var signatures: [Types_ValidatorSignature] {
    get {return _storage._signatures}
    set {_uniqueStorage()._signatures = newValue}
  }

  var ledgerInfo: Types_LedgerInfo {
    get {return _storage._ledgerInfo ?? Types_LedgerInfo()}
    set {_uniqueStorage()._ledgerInfo = newValue}
  }
  /// Returns true if `ledgerInfo` has been explicitly set.
  var hasLedgerInfo: Bool {return _storage._ledgerInfo != nil}
  /// Clears the value of `ledgerInfo`. Subsequent reads from it will return its default value.
  mutating func clearLedgerInfo() {_uniqueStorage()._ledgerInfo = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

struct Types_ValidatorSignature {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The account address of the validator, which can be used for retrieving its
  /// public key during the given epoch.
  var validatorID: Data = SwiftProtobuf.Internal.emptyData

  var signature: Data = SwiftProtobuf.Internal.emptyData

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "types"

extension Types_LedgerInfo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".LedgerInfo"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "version"),
    2: .standard(proto: "transaction_accumulator_hash"),
    3: .standard(proto: "consensus_data_hash"),
    4: .standard(proto: "consensus_block_id"),
    5: .same(proto: "epoch"),
    6: .same(proto: "round"),
    7: .standard(proto: "timestamp_usecs"),
    8: .standard(proto: "next_validator_set"),
  ]

  fileprivate class _StorageClass {
    var _version: UInt64 = 0
    var _transactionAccumulatorHash: Data = SwiftProtobuf.Internal.emptyData
    var _consensusDataHash: Data = SwiftProtobuf.Internal.emptyData
    var _consensusBlockID: Data = SwiftProtobuf.Internal.emptyData
    var _epoch: UInt64 = 0
    var _round: UInt64 = 0
    var _timestampUsecs: UInt64 = 0
    var _nextValidatorSet: Types_ValidatorSet? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _version = source._version
      _transactionAccumulatorHash = source._transactionAccumulatorHash
      _consensusDataHash = source._consensusDataHash
      _consensusBlockID = source._consensusBlockID
      _epoch = source._epoch
      _round = source._round
      _timestampUsecs = source._timestampUsecs
      _nextValidatorSet = source._nextValidatorSet
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        switch fieldNumber {
        case 1: try decoder.decodeSingularUInt64Field(value: &_storage._version)
        case 2: try decoder.decodeSingularBytesField(value: &_storage._transactionAccumulatorHash)
        case 3: try decoder.decodeSingularBytesField(value: &_storage._consensusDataHash)
        case 4: try decoder.decodeSingularBytesField(value: &_storage._consensusBlockID)
        case 5: try decoder.decodeSingularUInt64Field(value: &_storage._epoch)
        case 6: try decoder.decodeSingularUInt64Field(value: &_storage._round)
        case 7: try decoder.decodeSingularUInt64Field(value: &_storage._timestampUsecs)
        case 8: try decoder.decodeSingularMessageField(value: &_storage._nextValidatorSet)
        default: break
        }
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if _storage._version != 0 {
        try visitor.visitSingularUInt64Field(value: _storage._version, fieldNumber: 1)
      }
      if !_storage._transactionAccumulatorHash.isEmpty {
        try visitor.visitSingularBytesField(value: _storage._transactionAccumulatorHash, fieldNumber: 2)
      }
      if !_storage._consensusDataHash.isEmpty {
        try visitor.visitSingularBytesField(value: _storage._consensusDataHash, fieldNumber: 3)
      }
      if !_storage._consensusBlockID.isEmpty {
        try visitor.visitSingularBytesField(value: _storage._consensusBlockID, fieldNumber: 4)
      }
      if _storage._epoch != 0 {
        try visitor.visitSingularUInt64Field(value: _storage._epoch, fieldNumber: 5)
      }
      if _storage._round != 0 {
        try visitor.visitSingularUInt64Field(value: _storage._round, fieldNumber: 6)
      }
      if _storage._timestampUsecs != 0 {
        try visitor.visitSingularUInt64Field(value: _storage._timestampUsecs, fieldNumber: 7)
      }
      if let v = _storage._nextValidatorSet {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 8)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Types_LedgerInfo, rhs: Types_LedgerInfo) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._version != rhs_storage._version {return false}
        if _storage._transactionAccumulatorHash != rhs_storage._transactionAccumulatorHash {return false}
        if _storage._consensusDataHash != rhs_storage._consensusDataHash {return false}
        if _storage._consensusBlockID != rhs_storage._consensusBlockID {return false}
        if _storage._epoch != rhs_storage._epoch {return false}
        if _storage._round != rhs_storage._round {return false}
        if _storage._timestampUsecs != rhs_storage._timestampUsecs {return false}
        if _storage._nextValidatorSet != rhs_storage._nextValidatorSet {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Types_LedgerInfoWithSignatures: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".LedgerInfoWithSignatures"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "signatures"),
    2: .standard(proto: "ledger_info"),
  ]

  fileprivate class _StorageClass {
    var _signatures: [Types_ValidatorSignature] = []
    var _ledgerInfo: Types_LedgerInfo? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _signatures = source._signatures
      _ledgerInfo = source._ledgerInfo
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        switch fieldNumber {
        case 1: try decoder.decodeRepeatedMessageField(value: &_storage._signatures)
        case 2: try decoder.decodeSingularMessageField(value: &_storage._ledgerInfo)
        default: break
        }
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if !_storage._signatures.isEmpty {
        try visitor.visitRepeatedMessageField(value: _storage._signatures, fieldNumber: 1)
      }
      if let v = _storage._ledgerInfo {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Types_LedgerInfoWithSignatures, rhs: Types_LedgerInfoWithSignatures) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._signatures != rhs_storage._signatures {return false}
        if _storage._ledgerInfo != rhs_storage._ledgerInfo {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Types_ValidatorSignature: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ValidatorSignature"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "validator_id"),
    2: .same(proto: "signature"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularBytesField(value: &self.validatorID)
      case 2: try decoder.decodeSingularBytesField(value: &self.signature)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.validatorID.isEmpty {
      try visitor.visitSingularBytesField(value: self.validatorID, fieldNumber: 1)
    }
    if !self.signature.isEmpty {
      try visitor.visitSingularBytesField(value: self.signature, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Types_ValidatorSignature, rhs: Types_ValidatorSignature) -> Bool {
    if lhs.validatorID != rhs.validatorID {return false}
    if lhs.signature != rhs.signature {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
