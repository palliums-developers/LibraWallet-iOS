// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: transaction.proto
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

/// An argument to the transaction if the transaction takes arguments
struct Types_TransactionArgument {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var unknownFields = SwiftProtobuf.UnknownStorage()

  enum ArgType: SwiftProtobuf.Enum {
    typealias RawValue = Int
    case u64 // = 0
    case address // = 1
    case string // = 2
    case bytearray // = 3
    case UNRECOGNIZED(Int)

    init() {
      self = .u64
    }

    init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .u64
      case 1: self = .address
      case 2: self = .string
      case 3: self = .bytearray
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    var rawValue: Int {
      switch self {
      case .u64: return 0
      case .address: return 1
      case .string: return 2
      case .bytearray: return 3
      case .UNRECOGNIZED(let i): return i
      }
    }

  }

  init() {}
}

/// A generic structure that represents signed RawTransaction
struct Types_SignedTransaction {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// LCS byte code representation of a SignedTransaction
  var signedTxn: Data = SwiftProtobuf.Internal.emptyData

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Types_SignedTransactionWithProof {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The version of the returned signed transaction.
  var version: UInt64 {
    get {return _storage._version}
    set {_uniqueStorage()._version = newValue}
  }

  /// The transaction itself.
  var signedTransaction: Types_SignedTransaction {
    get {return _storage._signedTransaction ?? Types_SignedTransaction()}
    set {_uniqueStorage()._signedTransaction = newValue}
  }
  /// Returns true if `signedTransaction` has been explicitly set.
  var hasSignedTransaction: Bool {return _storage._signedTransaction != nil}
  /// Clears the value of `signedTransaction`. Subsequent reads from it will return its default value.
  mutating func clearSignedTransaction() {_storage._signedTransaction = nil}

  /// The proof authenticating the signed transaction.
  var proof: Types_SignedTransactionProof {
    get {return _storage._proof ?? Types_SignedTransactionProof()}
    set {_uniqueStorage()._proof = newValue}
  }
  /// Returns true if `proof` has been explicitly set.
  var hasProof: Bool {return _storage._proof != nil}
  /// Clears the value of `proof`. Subsequent reads from it will return its default value.
  mutating func clearProof() {_storage._proof = nil}

  /// The events yielded by executing the transaction, if requested.
  var events: Types_EventsList {
    get {return _storage._events ?? Types_EventsList()}
    set {_uniqueStorage()._events = newValue}
  }
  /// Returns true if `events` has been explicitly set.
  var hasEvents: Bool {return _storage._events != nil}
  /// Clears the value of `events`. Subsequent reads from it will return its default value.
  mutating func clearEvents() {_storage._events = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

/// A generic structure that represents a block of transactions originated from a
/// particular validator instance.
struct Types_SignedTransactionsBlock {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Set of Signed Transactions
  var transactions: [Types_SignedTransaction] = []

  /// Public key of the validator that created this block
  var validatorPublicKey: Data = SwiftProtobuf.Internal.emptyData

  /// Signature of the validator that created this block
  var validatorSignature: Data = SwiftProtobuf.Internal.emptyData

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// Account state as a whole.
/// After execution, updates to accounts are passed in this form to storage for
/// persistence.
struct Types_AccountState {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Account address
  var address: Data = SwiftProtobuf.Internal.emptyData

  /// Account state blob
  var blob: Data = SwiftProtobuf.Internal.emptyData

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// Transaction struct to commit to storage
struct Types_TransactionToCommit {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The signed transaction which was executed
  var signedTxn: Types_SignedTransaction {
    get {return _storage._signedTxn ?? Types_SignedTransaction()}
    set {_uniqueStorage()._signedTxn = newValue}
  }
  /// Returns true if `signedTxn` has been explicitly set.
  var hasSignedTxn: Bool {return _storage._signedTxn != nil}
  /// Clears the value of `signedTxn`. Subsequent reads from it will return its default value.
  mutating func clearSignedTxn() {_storage._signedTxn = nil}

  /// State db updates
  var accountStates: [Types_AccountState] {
    get {return _storage._accountStates}
    set {_uniqueStorage()._accountStates = newValue}
  }

  /// Events yielded by the transaction.
  var events: [Types_Event] {
    get {return _storage._events}
    set {_uniqueStorage()._events = newValue}
  }

  /// The amount of gas used.
  var gasUsed: UInt64 {
    get {return _storage._gasUsed}
    set {_uniqueStorage()._gasUsed = newValue}
  }

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

/// A list of consecutive transactions with proof. This is mainly used for state
/// synchronization when a validator would request a list of transactions from a
/// peer, verify the proof, execute the transactions and persist them. Note that
/// the transactions are supposed to belong to the same epoch E, otherwise
/// verification will fail.
struct Types_TransactionListWithProof {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The list of transactions.
  var transactions: [Types_SignedTransaction] {
    get {return _storage._transactions}
    set {_uniqueStorage()._transactions = newValue}
  }

  /// The list of corresponding TransactionInfo objects.
  var infos: [Types_TransactionInfo] {
    get {return _storage._infos}
    set {_uniqueStorage()._infos = newValue}
  }

  /// The list of corresponding Event objects (only present if fetch_events was set to true in req)
  var eventsForVersions: Types_EventsForVersions {
    get {return _storage._eventsForVersions ?? Types_EventsForVersions()}
    set {_uniqueStorage()._eventsForVersions = newValue}
  }
  /// Returns true if `eventsForVersions` has been explicitly set.
  var hasEventsForVersions: Bool {return _storage._eventsForVersions != nil}
  /// Clears the value of `eventsForVersions`. Subsequent reads from it will return its default value.
  mutating func clearEventsForVersions() {_storage._eventsForVersions = nil}

  /// If the list is not empty, the version of the first transaction.
  var firstTransactionVersion: SwiftProtobuf.Google_Protobuf_UInt64Value {
    get {return _storage._firstTransactionVersion ?? SwiftProtobuf.Google_Protobuf_UInt64Value()}
    set {_uniqueStorage()._firstTransactionVersion = newValue}
  }
  /// Returns true if `firstTransactionVersion` has been explicitly set.
  var hasFirstTransactionVersion: Bool {return _storage._firstTransactionVersion != nil}
  /// Clears the value of `firstTransactionVersion`. Subsequent reads from it will return its default value.
  mutating func clearFirstTransactionVersion() {_storage._firstTransactionVersion = nil}

  /// The proofs of the first and last transaction in this chunk. When this is
  /// used for state synchronization, the validator who requests the transactions
  /// will provide a version in the request and the proofs will be relative to
  /// the given version. When this is returned in GetTransactionsResponse, the
  /// proofs will be relative to the ledger info returned in
  /// UpdateToLatestLedgerResponse.
  var proofOfFirstTransaction: Types_AccumulatorProof {
    get {return _storage._proofOfFirstTransaction ?? Types_AccumulatorProof()}
    set {_uniqueStorage()._proofOfFirstTransaction = newValue}
  }
  /// Returns true if `proofOfFirstTransaction` has been explicitly set.
  var hasProofOfFirstTransaction: Bool {return _storage._proofOfFirstTransaction != nil}
  /// Clears the value of `proofOfFirstTransaction`. Subsequent reads from it will return its default value.
  mutating func clearProofOfFirstTransaction() {_storage._proofOfFirstTransaction = nil}

  var proofOfLastTransaction: Types_AccumulatorProof {
    get {return _storage._proofOfLastTransaction ?? Types_AccumulatorProof()}
    set {_uniqueStorage()._proofOfLastTransaction = newValue}
  }
  /// Returns true if `proofOfLastTransaction` has been explicitly set.
  var hasProofOfLastTransaction: Bool {return _storage._proofOfLastTransaction != nil}
  /// Clears the value of `proofOfLastTransaction`. Subsequent reads from it will return its default value.
  mutating func clearProofOfLastTransaction() {_storage._proofOfLastTransaction = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "types"

extension Types_TransactionArgument: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".TransactionArgument"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: Types_TransactionArgument) -> Bool {
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension Types_TransactionArgument.ArgType: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "U64"),
    1: .same(proto: "ADDRESS"),
    2: .same(proto: "STRING"),
    3: .same(proto: "BYTEARRAY"),
  ]
}

extension Types_SignedTransaction: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".SignedTransaction"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    5: .standard(proto: "signed_txn"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 5: try decoder.decodeSingularBytesField(value: &self.signedTxn)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.signedTxn.isEmpty {
      try visitor.visitSingularBytesField(value: self.signedTxn, fieldNumber: 5)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: Types_SignedTransaction) -> Bool {
    if self.signedTxn != other.signedTxn {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension Types_SignedTransactionWithProof: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".SignedTransactionWithProof"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "version"),
    2: .standard(proto: "signed_transaction"),
    3: .same(proto: "proof"),
    4: .same(proto: "events"),
  ]

  fileprivate class _StorageClass {
    var _version: UInt64 = 0
    var _signedTransaction: Types_SignedTransaction? = nil
    var _proof: Types_SignedTransactionProof? = nil
    var _events: Types_EventsList? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _version = source._version
      _signedTransaction = source._signedTransaction
      _proof = source._proof
      _events = source._events
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
        case 2: try decoder.decodeSingularMessageField(value: &_storage._signedTransaction)
        case 3: try decoder.decodeSingularMessageField(value: &_storage._proof)
        case 4: try decoder.decodeSingularMessageField(value: &_storage._events)
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
      if let v = _storage._signedTransaction {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      }
      if let v = _storage._proof {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
      }
      if let v = _storage._events {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: Types_SignedTransactionWithProof) -> Bool {
    if _storage !== other._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((_storage, other._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let other_storage = _args.1
        if _storage._version != other_storage._version {return false}
        if _storage._signedTransaction != other_storage._signedTransaction {return false}
        if _storage._proof != other_storage._proof {return false}
        if _storage._events != other_storage._events {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension Types_SignedTransactionsBlock: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".SignedTransactionsBlock"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "transactions"),
    2: .standard(proto: "validator_public_key"),
    3: .standard(proto: "validator_signature"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeRepeatedMessageField(value: &self.transactions)
      case 2: try decoder.decodeSingularBytesField(value: &self.validatorPublicKey)
      case 3: try decoder.decodeSingularBytesField(value: &self.validatorSignature)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.transactions.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.transactions, fieldNumber: 1)
    }
    if !self.validatorPublicKey.isEmpty {
      try visitor.visitSingularBytesField(value: self.validatorPublicKey, fieldNumber: 2)
    }
    if !self.validatorSignature.isEmpty {
      try visitor.visitSingularBytesField(value: self.validatorSignature, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: Types_SignedTransactionsBlock) -> Bool {
    if self.transactions != other.transactions {return false}
    if self.validatorPublicKey != other.validatorPublicKey {return false}
    if self.validatorSignature != other.validatorSignature {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension Types_AccountState: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".AccountState"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "address"),
    2: .same(proto: "blob"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularBytesField(value: &self.address)
      case 2: try decoder.decodeSingularBytesField(value: &self.blob)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.address.isEmpty {
      try visitor.visitSingularBytesField(value: self.address, fieldNumber: 1)
    }
    if !self.blob.isEmpty {
      try visitor.visitSingularBytesField(value: self.blob, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: Types_AccountState) -> Bool {
    if self.address != other.address {return false}
    if self.blob != other.blob {return false}
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension Types_TransactionToCommit: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".TransactionToCommit"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "signed_txn"),
    2: .standard(proto: "account_states"),
    3: .same(proto: "events"),
    4: .standard(proto: "gas_used"),
  ]

  fileprivate class _StorageClass {
    var _signedTxn: Types_SignedTransaction? = nil
    var _accountStates: [Types_AccountState] = []
    var _events: [Types_Event] = []
    var _gasUsed: UInt64 = 0

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _signedTxn = source._signedTxn
      _accountStates = source._accountStates
      _events = source._events
      _gasUsed = source._gasUsed
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
        case 1: try decoder.decodeSingularMessageField(value: &_storage._signedTxn)
        case 2: try decoder.decodeRepeatedMessageField(value: &_storage._accountStates)
        case 3: try decoder.decodeRepeatedMessageField(value: &_storage._events)
        case 4: try decoder.decodeSingularUInt64Field(value: &_storage._gasUsed)
        default: break
        }
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if let v = _storage._signedTxn {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
      }
      if !_storage._accountStates.isEmpty {
        try visitor.visitRepeatedMessageField(value: _storage._accountStates, fieldNumber: 2)
      }
      if !_storage._events.isEmpty {
        try visitor.visitRepeatedMessageField(value: _storage._events, fieldNumber: 3)
      }
      if _storage._gasUsed != 0 {
        try visitor.visitSingularUInt64Field(value: _storage._gasUsed, fieldNumber: 4)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: Types_TransactionToCommit) -> Bool {
    if _storage !== other._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((_storage, other._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let other_storage = _args.1
        if _storage._signedTxn != other_storage._signedTxn {return false}
        if _storage._accountStates != other_storage._accountStates {return false}
        if _storage._events != other_storage._events {return false}
        if _storage._gasUsed != other_storage._gasUsed {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if unknownFields != other.unknownFields {return false}
    return true
  }
}

extension Types_TransactionListWithProof: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".TransactionListWithProof"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "transactions"),
    2: .same(proto: "infos"),
    3: .standard(proto: "events_for_versions"),
    4: .standard(proto: "first_transaction_version"),
    5: .standard(proto: "proof_of_first_transaction"),
    6: .standard(proto: "proof_of_last_transaction"),
  ]

  fileprivate class _StorageClass {
    var _transactions: [Types_SignedTransaction] = []
    var _infos: [Types_TransactionInfo] = []
    var _eventsForVersions: Types_EventsForVersions? = nil
    var _firstTransactionVersion: SwiftProtobuf.Google_Protobuf_UInt64Value? = nil
    var _proofOfFirstTransaction: Types_AccumulatorProof? = nil
    var _proofOfLastTransaction: Types_AccumulatorProof? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _transactions = source._transactions
      _infos = source._infos
      _eventsForVersions = source._eventsForVersions
      _firstTransactionVersion = source._firstTransactionVersion
      _proofOfFirstTransaction = source._proofOfFirstTransaction
      _proofOfLastTransaction = source._proofOfLastTransaction
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
        case 1: try decoder.decodeRepeatedMessageField(value: &_storage._transactions)
        case 2: try decoder.decodeRepeatedMessageField(value: &_storage._infos)
        case 3: try decoder.decodeSingularMessageField(value: &_storage._eventsForVersions)
        case 4: try decoder.decodeSingularMessageField(value: &_storage._firstTransactionVersion)
        case 5: try decoder.decodeSingularMessageField(value: &_storage._proofOfFirstTransaction)
        case 6: try decoder.decodeSingularMessageField(value: &_storage._proofOfLastTransaction)
        default: break
        }
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if !_storage._transactions.isEmpty {
        try visitor.visitRepeatedMessageField(value: _storage._transactions, fieldNumber: 1)
      }
      if !_storage._infos.isEmpty {
        try visitor.visitRepeatedMessageField(value: _storage._infos, fieldNumber: 2)
      }
      if let v = _storage._eventsForVersions {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
      }
      if let v = _storage._firstTransactionVersion {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
      }
      if let v = _storage._proofOfFirstTransaction {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
      }
      if let v = _storage._proofOfLastTransaction {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 6)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  func _protobuf_generated_isEqualTo(other: Types_TransactionListWithProof) -> Bool {
    if _storage !== other._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((_storage, other._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let other_storage = _args.1
        if _storage._transactions != other_storage._transactions {return false}
        if _storage._infos != other_storage._infos {return false}
        if _storage._eventsForVersions != other_storage._eventsForVersions {return false}
        if _storage._firstTransactionVersion != other_storage._firstTransactionVersion {return false}
        if _storage._proofOfFirstTransaction != other_storage._proofOfFirstTransaction {return false}
        if _storage._proofOfLastTransaction != other_storage._proofOfLastTransaction {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if unknownFields != other.unknownFields {return false}
    return true
  }
}
