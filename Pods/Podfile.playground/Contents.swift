import UIKit

func unzipComicsinDiractory(withpath path: String) {

        let pathEndIndex = path.endIndex
        guard let dotindex = path.lastIndex(of: ".") else { return print("failed")}
        guard let slashIndex = path.lastIndex(of: "/") else { return print("failed2")}
        
    let formatRange = dotindex..<pathEndIndex
    let formatName = path.substring(with: formatRange).dropFirst()
        
        let nameRange = slashIndex..<dotindex
    let name = path.substring(with: nameRange).dropFirst()
        
        print(formatName)
        print(name)
        
        
       
         //todo!
        
        
    }
    


let pathString = "/Users/shayan/Documents/comics/Black Hammer - Age of Doom 012 (2019) (digital) (Son of Ultron-Empire).cbr"

unzipComicsinDiractory(withpath: pathString)

var str = "Hello, playground"
