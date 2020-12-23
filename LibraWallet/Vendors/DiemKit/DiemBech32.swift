//
//  DiemBech32.swift
//  LibraWallet
//
//  Created by wangyingdong on 2020/11/27.
//  Copyright © 2020 palliums. All rights reserved.
//

import UIKit

public struct DiemBech32 {
    internal static let base32Alphabets = "qpzry9x8gf2tvdw0s3jn54khce6mua7l"
    
    /// Encodes the data to Bech32 encoded string
    ///
    /// Creates checksum bytes from the prefix and the payload, and then puts the
    /// checksum bytes to the original data. Then, encode the combined data to
    /// Base32 string. At last, returns the combined string of prefix, separator
    /// and the encoded base32 text.
    /// ```
    /// let address = Base58Check.encode(payload: [versionByte] + pubkeyHash,
    ///                                  prefix: "bitcoincash")
    /// ```
    /// - Parameters:
    ///   - payload: The data to encode
    ///   - prefix: The prefix of the encoded text. It is also used to create checksum.
    ///   - version: The prefix of version
    ///   - separator: separator that separates prefix and Base32 encoded text
    /// - Returns: encode string
    public static func encode(payload: Data, prefix: String, version: UInt8, separator: String = "1") -> String {
        let payloadUint5 = convertTo5bit(data: payload, pad: true)
        let checksumUint5: Data = createChecksum(prefix: prefix, payload: Data([version]) + payloadUint5) // Data of [UInt5]
        let combined: Data = Data([version]) + payloadUint5 + checksumUint5 // Data of [UInt5]
        var base32 = ""
        for b in combined {
            let index = String.Index(utf16Offset: Int(b), in: base32Alphabets)
            base32 += String(base32Alphabets[index])
        }
        return prefix + separator + base32
    }
    /// Decodes the Bech32 encoded string to original payload
    ///
    /// ```
    /// // Decode address to bytes
    /// guard let payload: Data = Bech32.decode(text: address) else {
    ///     // Invalid checksum or Bech32 coding
    ///     throw SomeError()
    /// }
    /// let versionByte = payload[0]
    /// let pubkeyHash = payload.dropFirst()
    /// ```
    /// - Parameters:
    ///   - string: The data to encode
    ///   - separator: separator that separates prefix and Base32 encoded text
    public static func decode(_ string: String, version: UInt8 = 1, separator: String = "1") throws -> (prefix: String, data: Data) {
        // We can't have empty string.
        // Bech32 should be uppercase only / lowercase only.
        guard !string.isEmpty && [string.lowercased(), string.uppercased()].contains(string) else {
            throw DecodeError.decodeDataStringEmpty
        }
        let components = string.components(separatedBy: separator)
        // We can only handle string contains both scheme and base32
        guard components.count == 2 else {
            throw DecodeError.invalidSeparator
        }
        let (prefix, base32) = (components[0], components[1])
        
        var decodedIn5bit: [UInt8] = [UInt8]()
        for c in base32.dropFirst().lowercased() {
            // We can't have characters other than base32 alphabets.
            guard let baseIndex = base32Alphabets.firstIndex(of: c)?.utf16Offset(in: base32Alphabets) else {
                throw DecodeError.invalidCharacter
            }
            decodedIn5bit.append(UInt8(baseIndex))
        }
        
        // We can't have invalid checksum
        let payload = Data(decodedIn5bit)
        guard verifyChecksum(prefix: prefix, version: version, payload: payload) else {
            throw DecodeError.verifyChecksumFailed
        }
        
        // Drop checksum
        do {
            let bytes = try convertFrom5bit(data: payload.dropLast(6))
            return (prefix, Data(bytes))
        } catch {
            throw error
        }
    }
    
    internal static func verifyChecksum(prefix: String, version: UInt8, payload: Data) -> Bool {
        return PolyMod(expand(prefix) + Data([version]) + payload) == 0
    }
    
    internal static func expand(_ prefix: String) -> Data {
        var ret: Data = Data()
        let buf: [UInt8] = Array(prefix.utf8)
        for b in buf {
//            ret += ((b & 0x7f) >> 5) & 0x7
            ret.append(((b & 0x7f) >> 5) & 0x7)
        }
        ret += Data(repeating: 0, count: 1)
        for b in buf {
//            ret += (b & 0x7f) & 0x1f
            ret .append((b & 0x7f) & 0x1f)
        }
        return ret
    }
    
    internal static func createChecksum(prefix: String, payload: Data) -> Data {
        let enc: Data = expand(prefix) + payload + Data(repeating: 0, count: 6)
        let mod: UInt64 = PolyMod(enc)
        var ret: Data = Data()
        for i in 0..<6 {
//            ret += UInt8((mod >> (5 * (5 - i))) & 0x1f)
            ret.append(UInt8((mod >> (5 * (5 - i))) & 0x1f))
        }
        return ret
    }
    
    internal static func PolyMod(_ data: Data) -> UInt64 {
        var c: UInt64 = 1
        let GENERATOR = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3];
        for d in data {
            let c0: UInt8 = UInt8(c >> 25)
            c = (c & 0x1ffffff) << 5 ^ UInt64(d)
            for i in 0..<5 {
                if (((c0 >> i) & 1) == 1) {
                    c ^= UInt64(GENERATOR[i])
                } else {
                    c ^= 0
                }
            }
        }
        return c ^ 1
    }
    
    internal static func convertTo5bit(data: Data, pad: Bool) -> Data {
        var acc = Int()
        var bits = UInt8()
        let maxv: Int = 31 // 31 = 0x1f = 00011111
        var converted: [UInt8] = []
        for d in data {
            acc = (acc << 8) | Int(d)
            bits += 8
            
            while bits >= 5 {
                bits -= 5
                converted.append(UInt8(acc >> Int(bits) & maxv))
            }
        }
        
        let lastBits: UInt8 = UInt8(acc << (5 - bits) & maxv)
        if pad && bits > 0 {
            converted.append(lastBits)
        }
        return Data(converted)
    }
    
    internal static func convertFrom5bit(data: Data) throws -> Data {
        var acc = Int()
        var bits = UInt8()
        let maxv: Int = 255 // 255 = 0xff = 11111111
        var converted: [UInt8] = []
        for d in data {
            guard (d >> 5) == 0 else {
                throw DecodeError.invalidCharacter
            }
            acc = (acc << 5) | Int(d)
            bits += 5
            
            while bits >= 8 {
                bits -= 8
                converted.append(UInt8(acc >> Int(bits) & maxv))
            }
        }
        
        let lastBits: UInt8 = UInt8(acc << (8 - bits) & maxv)
        guard bits < 5 && lastBits == 0  else {
            throw DecodeError.invalidBits
        }
        
        return Data(converted)
    }
    
    internal enum DecodeError: Error {
        //        case nonUTF8String
        //        case nonPrintableCharacter
        //        case invalidCase
        //        case noChecksumMarker
        //        case incorrectHrpSize
        //        case incorrectChecksumSize
        //        case stringLengthExceeded
        
        case invalidCharacter
        case invalidBits
        
        case decodeDataStringEmpty
        case invalidSeparator
        case verifyChecksumFailed
    }
}
