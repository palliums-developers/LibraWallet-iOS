// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: network.proto
//
// For information on using the generated types, please see the documentation:
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

/// A `PeerInfo` represents the network address(es) of a Peer.
struct Network_PeerInfo {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Monotonically increasing incarnation number used to allow peers to issue
  /// updates to their `PeerInfo` and prevent attackers from propagating old
  /// `PeerInfo`s. This is usually a timestamp.
  var epoch: UInt64 = 0

  /// Network addresses this peer can be reached at. An address is a serialized
  /// [multiaddr](https://multiformats.io/multiaddr/).
  var addrs: [Data] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// A `PeerInfo` authenticated by the peer's root `network_signing_key` stored
/// on-chain.
struct Network_SignedPeerInfo {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// A serialized `PeerInfo`.
  var peerInfo: Data = SwiftProtobuf.Internal.emptyData

  /// A signature over the above serialzed `PeerInfo`, signed by the validator's
  /// `network_signing_key` referred to by the `peer_id` account address.
  var signature: Data = SwiftProtobuf.Internal.emptyData

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// Discovery information relevant to public full nodes and clients.
struct Network_FullNodePayload {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Monotonically increasing incarnation number used to allow peers to issue
  /// updates to their `FullNodePayload` and prevent attackers from propagating
  /// old `FullNodePayload`s. This is usually a timestamp.
  var epoch: UInt64 = 0

  /// The DNS domain name other public full nodes should query to get this
  /// validator's list of full nodes.
  var dnsSeedAddr: Data = SwiftProtobuf.Internal.emptyData

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// A signed `FullNodePayload`.
struct Network_SignedFullNodePayload {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// A serialized `FullNodePayload`.
  var payload: Data = SwiftProtobuf.Internal.emptyData

  /// A signature over `payload` signed by the validator's `network_signing_key`
  /// referred to by the `peer_id` account address.
  var signature: Data = SwiftProtobuf.Internal.emptyData

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// A `Note` contains a validator's signed `PeerInfo` as well as a signed
/// `FullNodePayload`, which provides relevant discovery info for public full
/// nodes and clients.
struct Network_Note {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Id of the peer.
  var peerID: Data {
    get {return _storage._peerID}
    set {_uniqueStorage()._peerID = newValue}
  }

  /// The validator node's signed `PeerInfo`.
  var signedPeerInfo: Network_SignedPeerInfo {
    get {return _storage._signedPeerInfo ?? Network_SignedPeerInfo()}
    set {_uniqueStorage()._signedPeerInfo = newValue}
  }
  /// Returns true if `signedPeerInfo` has been explicitly set.
  var hasSignedPeerInfo: Bool {return _storage._signedPeerInfo != nil}
  /// Clears the value of `signedPeerInfo`. Subsequent reads from it will return its default value.
  mutating func clearSignedPeerInfo() {_uniqueStorage()._signedPeerInfo = nil}

  /// The validator node's signed `FullNodePayload`.
  var signedFullNodePayload: Network_SignedFullNodePayload {
    get {return _storage._signedFullNodePayload ?? Network_SignedFullNodePayload()}
    set {_uniqueStorage()._signedFullNodePayload = newValue}
  }
  /// Returns true if `signedFullNodePayload` has been explicitly set.
  var hasSignedFullNodePayload: Bool {return _storage._signedFullNodePayload != nil}
  /// Clears the value of `signedFullNodePayload`. Subsequent reads from it will return its default value.
  mutating func clearSignedFullNodePayload() {_uniqueStorage()._signedFullNodePayload = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

/// Discovery message exchanged as part of the discovery protocol.
/// The discovery message sent by a peer consists of notes for all the peers the
/// sending peer knows about.
struct Network_DiscoveryMsg {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var notes: [Network_Note] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// Identity message exchanged as part of the Identity protocol.
struct Network_IdentityMsg {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var peerID: Data = SwiftProtobuf.Internal.emptyData

  var supportedProtocols: [Data] = []

  var role: Network_IdentityMsg.Role = .validator

  var unknownFields = SwiftProtobuf.UnknownStorage()

  enum Role: SwiftProtobuf.Enum {
    typealias RawValue = Int
    case validator // = 0
    case fullNode // = 1
    case UNRECOGNIZED(Int)

    init() {
      self = .validator
    }

    init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .validator
      case 1: self = .fullNode
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    var rawValue: Int {
      switch self {
      case .validator: return 0
      case .fullNode: return 1
      case .UNRECOGNIZED(let i): return i
      }
    }

  }

  init() {}
}

#if swift(>=4.2)

extension Network_IdentityMsg.Role: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [Network_IdentityMsg.Role] = [
    .validator,
    .fullNode,
  ]
}

#endif  // swift(>=4.2)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "network"

extension Network_PeerInfo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".PeerInfo"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "epoch"),
    2: .same(proto: "addrs"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt64Field(value: &self.epoch)
      case 2: try decoder.decodeRepeatedBytesField(value: &self.addrs)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.epoch != 0 {
      try visitor.visitSingularUInt64Field(value: self.epoch, fieldNumber: 1)
    }
    if !self.addrs.isEmpty {
      try visitor.visitRepeatedBytesField(value: self.addrs, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Network_PeerInfo, rhs: Network_PeerInfo) -> Bool {
    if lhs.epoch != rhs.epoch {return false}
    if lhs.addrs != rhs.addrs {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Network_SignedPeerInfo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".SignedPeerInfo"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "peer_info"),
    2: .same(proto: "signature"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularBytesField(value: &self.peerInfo)
      case 2: try decoder.decodeSingularBytesField(value: &self.signature)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.peerInfo.isEmpty {
      try visitor.visitSingularBytesField(value: self.peerInfo, fieldNumber: 1)
    }
    if !self.signature.isEmpty {
      try visitor.visitSingularBytesField(value: self.signature, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Network_SignedPeerInfo, rhs: Network_SignedPeerInfo) -> Bool {
    if lhs.peerInfo != rhs.peerInfo {return false}
    if lhs.signature != rhs.signature {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Network_FullNodePayload: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".FullNodePayload"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "epoch"),
    2: .standard(proto: "dns_seed_addr"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt64Field(value: &self.epoch)
      case 2: try decoder.decodeSingularBytesField(value: &self.dnsSeedAddr)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.epoch != 0 {
      try visitor.visitSingularUInt64Field(value: self.epoch, fieldNumber: 1)
    }
    if !self.dnsSeedAddr.isEmpty {
      try visitor.visitSingularBytesField(value: self.dnsSeedAddr, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Network_FullNodePayload, rhs: Network_FullNodePayload) -> Bool {
    if lhs.epoch != rhs.epoch {return false}
    if lhs.dnsSeedAddr != rhs.dnsSeedAddr {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Network_SignedFullNodePayload: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".SignedFullNodePayload"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "payload"),
    2: .same(proto: "signature"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularBytesField(value: &self.payload)
      case 2: try decoder.decodeSingularBytesField(value: &self.signature)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.payload.isEmpty {
      try visitor.visitSingularBytesField(value: self.payload, fieldNumber: 1)
    }
    if !self.signature.isEmpty {
      try visitor.visitSingularBytesField(value: self.signature, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Network_SignedFullNodePayload, rhs: Network_SignedFullNodePayload) -> Bool {
    if lhs.payload != rhs.payload {return false}
    if lhs.signature != rhs.signature {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Network_Note: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Note"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "peer_id"),
    2: .standard(proto: "signed_peer_info"),
    3: .standard(proto: "signed_full_node_payload"),
  ]

  fileprivate class _StorageClass {
    var _peerID: Data = SwiftProtobuf.Internal.emptyData
    var _signedPeerInfo: Network_SignedPeerInfo? = nil
    var _signedFullNodePayload: Network_SignedFullNodePayload? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _peerID = source._peerID
      _signedPeerInfo = source._signedPeerInfo
      _signedFullNodePayload = source._signedFullNodePayload
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
        case 1: try decoder.decodeSingularBytesField(value: &_storage._peerID)
        case 2: try decoder.decodeSingularMessageField(value: &_storage._signedPeerInfo)
        case 3: try decoder.decodeSingularMessageField(value: &_storage._signedFullNodePayload)
        default: break
        }
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if !_storage._peerID.isEmpty {
        try visitor.visitSingularBytesField(value: _storage._peerID, fieldNumber: 1)
      }
      if let v = _storage._signedPeerInfo {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      }
      if let v = _storage._signedFullNodePayload {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Network_Note, rhs: Network_Note) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._peerID != rhs_storage._peerID {return false}
        if _storage._signedPeerInfo != rhs_storage._signedPeerInfo {return false}
        if _storage._signedFullNodePayload != rhs_storage._signedFullNodePayload {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Network_DiscoveryMsg: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".DiscoveryMsg"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "notes"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeRepeatedMessageField(value: &self.notes)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.notes.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.notes, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Network_DiscoveryMsg, rhs: Network_DiscoveryMsg) -> Bool {
    if lhs.notes != rhs.notes {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Network_IdentityMsg: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".IdentityMsg"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "peer_id"),
    2: .standard(proto: "supported_protocols"),
    3: .same(proto: "role"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularBytesField(value: &self.peerID)
      case 2: try decoder.decodeRepeatedBytesField(value: &self.supportedProtocols)
      case 3: try decoder.decodeSingularEnumField(value: &self.role)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.peerID.isEmpty {
      try visitor.visitSingularBytesField(value: self.peerID, fieldNumber: 1)
    }
    if !self.supportedProtocols.isEmpty {
      try visitor.visitRepeatedBytesField(value: self.supportedProtocols, fieldNumber: 2)
    }
    if self.role != .validator {
      try visitor.visitSingularEnumField(value: self.role, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Network_IdentityMsg, rhs: Network_IdentityMsg) -> Bool {
    if lhs.peerID != rhs.peerID {return false}
    if lhs.supportedProtocols != rhs.supportedProtocols {return false}
    if lhs.role != rhs.role {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Network_IdentityMsg.Role: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "VALIDATOR"),
    1: .same(proto: "FULL_NODE"),
  ]
}
