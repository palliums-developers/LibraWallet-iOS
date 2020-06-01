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
            return LibraWordList.english
        case .japanese:
            return LibraWordList.japanese
        case .korean:
            return LibraWordList.korean
        case .spanish:
            return LibraWordList.spanish
        case .simplifiedChinese:
            return LibraWordList.simplifiedChinese
        case .traditionalChinese:
            return LibraWordList.traditionalChinese
        case .french:
            return LibraWordList.french
        case .italian:
            return LibraWordList.italian
        }
    }
}
extension LibraMnemonic {
//    static func deriveLanguageFromMnemonic(words: [String]) -> Language? {
//        func tryLangauge(
//            _ language: Language
//        ) -> Language? {
//            let vocabulary = Set(wordList(for: language))
//            let wordsLeftToCheck = Set(words)
//
//            guard wordsLeftToCheck.intersection(vocabulary) == wordsLeftToCheck else {
//                return nil
//            }
//
//            return language
//        }
//
//        for langauge in Language.allCases {
//            guard let derived = tryLangauge(langauge) else { continue }
//            return derived
//        }
//        return nil
//    }
//
//    @discardableResult
//    static func validateChecksumDerivingLanguageOf(mnemonic mnemonicWords: [String]) throws -> Bool {
//        guard let derivedLanguage = deriveLanguageFromMnemonic(words: mnemonicWords) else {
//            throw MnemonicError.validationError(.unableToDeriveLanguageFrom(words: mnemonicWords))
//        }
//        return try validateChecksumOf(mnemonic: mnemonicWords, language: derivedLanguage)
//    }
//
//    // https://github.com/mcdallas/cryptotools/blob/master/btctools/HD/__init__.py#L27-L41
//    // alternative in C:
//    // https://github.com/trezor/trezor-crypto/blob/0c622d62e1f1e052c2292d39093222ce358ca7b0/bip39.c#L161-L179
//    @discardableResult
//    static func validateChecksumOf(mnemonic mnemonicWords: [String], language: Language) throws -> Bool {
//        let vocabulary = wordList(for: language)
//
//        let indices: [UInt11] = try mnemonicWords.map { word in
//            guard let indexInVocabulary = vocabulary.firstIndex(of: word) else {
//                throw MnemonicError.validationError(.wordNotInList(word, language: language))
//            }
//            guard let indexAs11Bits = UInt11(exactly: indexInVocabulary) else {
//                fatalError("Unexpected error, is word list longer than 2048 words, it shold not be")
//            }
//            return indexAs11Bits
//        }
//
//        let bitArray = BitArray(indices)
//
//        let checksumLength = mnemonicWords.count / 3//        let checksumBits = bitArray.suffix(maxCount: checksumLength)
//
//        let hash = Crypto.sha256(dataBits.asData())
//
//        let hashBits = BitArray(data: hash).prefix(maxCount: checksumLength)
//
//        guard hashBits == checksumBits else {
//            throw MnemonicError.validationError(.checksumMismatch)
//        }
//
//        // All is well
//        return true
//    }
}
public enum MnemonicError: Error {
    case randomBytesError
//    case badWordCount(expectedAnyOf: [Int], butGot: Int)
//    case wordNotInList(String, language: Mnemonic.Language)
//    case unableToDeriveLanguageFrom(words: [String])
//    case checksumMismatch
}
