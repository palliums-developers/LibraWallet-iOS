//
//  Mnemonic.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import Foundation
import CryptoSwift
struct LibraMnemonic {
    public enum Strength: Int {
        case `default` = 128
        case low = 160
        case medium = 192
        case high = 224
        case veryHigh = 256
    }
    
    public enum Language {
        case english
        case japanese
        case korean
        case spanish
        case simplifiedChinese
        case traditionalChinese
        case french
        case italian
    }
    
    public static func generate(strength: Strength = .default, language: Language = .english) throws -> [String] {
        let byteCount = strength.rawValue / 8
        var bytes = Data(count: byteCount)
        let status = bytes.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, byteCount, $0.baseAddress!)}
//        let status = bytes.withUnsafeMutableBytes { (buffer) in
//            SecRandomCopyBytes(kSecRandomDefault, byteCount, buffer.baseAddress!)
//        }
        guard status == errSecSuccess else { throw MnemonicError.randomBytesError }
        return generate(entropy: bytes, language: language)
    }
    
    internal static func generate(entropy: Data, language: Language = .english) -> [String] {
        let list = wordList(for: language)
        var bin = String(entropy.flatMap { ("00000000" + String($0, radix: 2)).suffix(8) })
        
        let hash = entropy.sha256()//Crypto.sha256(entropy)
        let bits = entropy.count * 8
        let cs = bits / 32
        
        let hashbits = String(hash.flatMap { ("00000000" + String($0, radix: 2)).suffix(8) })
        let checksum = String(hashbits.prefix(cs))
        bin += checksum
        
        var mnemonic = [String]()
        for i in 0..<(bin.count / 11) {
            let wi = Int(bin[bin.index(bin.startIndex, offsetBy: i * 11)..<bin.index(bin.startIndex, offsetBy: (i + 1) * 11)], radix: 2)!
            mnemonic.append(String(list[wi]))
        }
        return mnemonic
    }

    public static func seed(mnemonic: [String]) throws -> [UInt8] {
        let salt: Array<UInt8> = Array("LIBRA WALLET: mnemonic salt prefix$LIBRA".utf8)
        let mnemonicTemp = mnemonic.joined(separator: " ")
        do {
            let dk = try PKCS5.PBKDF2(password: Array(mnemonicTemp.utf8), salt: salt, iterations: 2048, keyLength: 32, variant: .sha3_256).calculate()
//            let seed = try Seed.init(bytes: dk)
//            return seed
            return dk
        } catch {
            throw error
        }
    }
    private static func wordList(for language: Language) -> [String.SubSequence] {
        switch language {
        case .english:
            return WordList.english
        case .japanese:
            return WordList.japanese
        case .korean:
            return WordList.korean
        case .spanish:
            return WordList.spanish
        case .simplifiedChinese:
            return WordList.simplifiedChinese
        case .traditionalChinese:
            return WordList.traditionalChinese
        case .french:
            return WordList.french
        case .italian:
            return WordList.italian
        }
    }
}

public enum MnemonicError: Error {
    case randomBytesError
}

