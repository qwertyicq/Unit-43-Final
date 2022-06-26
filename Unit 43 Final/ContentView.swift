//
//  ContentView.swift
//  Unit 43 Final
//
//  Created by Nikolay T on 01.05.2022.
//

import SwiftUI
import Foundation
import Alamofire
import SwiftyJSON
import Kingfisher


struct ContentView: View {
    
    let API_URL: String = "https://www.breakingbadapi.com/api/characters"
    
    func GetData() async {
        DispatchQueue.global(qos: .background).async {
            let request = AF.request(API_URL)
            
            
            request.responseString { response in
                switch response.result {
                case .success(let value):
                    
                    let json = JSON(parseJSON: value)
                    let characters = json.arrayValue
                    
                    for index in 0..<characters.count {
                        let name = characters[index].dictionaryValue["name"]!.stringValue
                        
                        if self.array == nil {
                            let bDate = characters[index].dictionaryValue["birthday"]!.stringValue
                            let nickname = characters[index].dictionaryValue["nickname"]!.stringValue
                            let urlToImage = characters[index].dictionaryValue["img"]!.stringValue
                            let id = characters[index].dictionaryValue["char_id"]!.stringValue
                            
                            if let intID = Int(id) {
                                self.array = [CharacterBB(id: intID, name: name, nickname: nickname, bDate: bDate, urlToImage: urlToImage)]
                            } else {
                                self.array = [CharacterBB(id: -1, name: name, nickname: nickname, bDate: bDate, urlToImage: urlToImage)]
                            }
                        } else {
                            if self.array!.contains(where: { item in
                                if item.name == name {
                                    return true
                                } else {
                                    return false
                                }
                            }) {
                                continue
                            }
                            
                            let bDate = characters[index].dictionaryValue["birthday"]!.stringValue
                            let nickname = characters[index].dictionaryValue["nickname"]!.stringValue
                            let urlToImage = characters[index].dictionaryValue["img"]!.stringValue
                            let id = characters[index].dictionaryValue["char_id"]!.stringValue
                            
                            if let intID = Int(id) {
                                self.array!.append(CharacterBB(id: intID, name: name, nickname: nickname, bDate: bDate, urlToImage: urlToImage))
                            } else {
                                self.array!.append(CharacterBB(id: -1, name: name, nickname: nickname, bDate: bDate, urlToImage: urlToImage))
                            }
                        }
                    }
                    break
                case .failure(let error):
                    print(error)
                    break
                }
            }
        }
    }
    
    @State var array: [CharacterBB]?
    
    var body: some View {
        
        NavigationView {
            if array == nil {
                Image("default")
                    .resizable()
                    .scaledToFit()
                    .task {
                        await GetData()
                    }
            } else {
                List(array!) { item in
                    NavigationLink(item.name, destination: DetailNewsView(currentCharacter: item))
                        .padding(.trailing)
                }.navigationTitle("Breaking Bad")
                    .task {
                        await GetData()
                    }
            }
        }
    }
}

struct DetailNewsView: View {
    let currentCharacter: CharacterBB
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(currentCharacter.name)
                .font(.largeTitle)
                .bold()
            KFImage(URL(string: currentCharacter.urlToImage))
                .resizable()
                .padding(.top)
                .scaledToFit()
            Spacer()
            Text("Birthday: \(currentCharacter.bDate)")
                .font(.subheadline)
                .padding()
            Text("Nickname: \(currentCharacter.nickname)")
                .font(.headline)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
