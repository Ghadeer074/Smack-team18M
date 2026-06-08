//
//  Logic.swift
//  Smack
//
//  Created by Ghadeer Fallatah on 19/11/1447 AH.
//
import Foundation
//import Combine

func generatorCode(length: Int = 6) -> String {
   let digits = "0123456789"
    return String((0..<length).compactMap { _ in digits.randomElement() })
}
