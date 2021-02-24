//
//  stringExtensions·swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 1/30/21·
//

extension String {
    
    func stringToMorse() -> String {
        var morse = ""
        let string = self
        for i in string {
            switch i.lowercased() {
            case "a":
                morse.append("·- ")
                break
            case "b":
                morse.append("-··· ")
                break
            case "c":
                morse.append("-·-· ")
                break
            case "d":
                morse.append("-·· ")
                break
            case "e":
                morse.append("· ")
                break
            case "f":
                morse.append("··-· ")
                break
            case "g":
                morse.append("--· ")
                break
            case "h":
                morse.append("···· ")
                break
            case "i":
                morse.append("·· ")
                break
            case "j":
                morse.append("·--- ")
                break
            case "k":
                morse.append("-·- ")
                break
            case "l":
                morse.append("·-·· ")
                break
            case "m":
                morse.append("-- ")
                break
            case "n":
                morse.append("-· ")
                break
            
            case "o":
                morse.append("--- ")
                break
            case "p":
                morse.append("·--· ")
                break
            case "q":
                morse.append("--·- ")
                break
            case "r":
                morse.append("·-· ")
                break
            case "s":
                morse.append("··· ")
                break
            case "t":
                morse.append("- ")
                break
            case "u":
                morse.append("··- ")
                break
            case "v":
                morse.append("···- ")
                break
            case "w":
                morse.append("·-- ")
                break
            case "x":
                morse.append("-··- ")
                break
            case "y":
                morse.append("-·-- ")
                break
            case "z":
                morse.append("--·· ")
                break
            case "1":
                morse.append("·---- ")
                break
            case "2":
                morse.append("··--- ")
                break
            case "3":
                morse.append("···-- ")
            case "4":
                morse.append("····- ")
                break
            case "5":
                morse.append("····· ")
                break
            case "6":
                morse.append("-···· ")
                break
            case "7":
                morse.append("--··· ")
                break
            case "8":
                morse.append("---·· ")
                break
            case "9":
                morse.append("----· ")
                break
            case "0":
                morse.append("----- ")
                break
            case "·":
                morse.append("·-·-·- ")
                break
            case ",":
                morse.append("--··-- ")
                break
            default:
                break
            }
        }
        return morse
    }
    
    func stringToBinary() -> String {
        let st = self
        var result = ""
        for char in st.utf8 {
            var tranformed = String(char, radix: 2)
            while tranformed.count < 8 {
                tranformed = "0" + tranformed
            }
            let binary = "\(tranformed) "
            result.append(binary)
        }
        return result
    }
}
