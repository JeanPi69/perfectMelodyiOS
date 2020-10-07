//
//  ContentView.swift
//  Perfect Melody
//
//  Created by JEAN PIERRE HUAPAYA CHAVEZ on 8/22/20.
//  Copyright © 2020 UPC. All rights reserved.
//

import Foundation
import SwiftUI
import AVKit
import Alamofire

struct ContentView: View {
        @State private var maxWidth: CGFloat = .zero
        
        @State var record = false
        @State var session: AVAudioSession!
        @State var recorder: AVAudioRecorder!
        @State var alert = false
        @State var audios: [URL] = []
        @State var player: AVAudioPlayer!
        @State var time: CGFloat = 0
        
        @State var isPresented = false
        
        @State var showingAlert = false
        
        @State var showButton = false
    
        @State var showModal = false
        
        @Environment(\.presentationMode) var presentationMode
    
        var body: some View{
            
            ZStack{
                    NavigationView{
                                VStack{
                                    Button(action:{
                                        do{
                                            if self.record{
                                                self.recorder.stop()
                                                self.record.toggle()
                                                self.getAudios()
                                                withAnimation{
                                                    self.isPresented.toggle()
                                                }
                                                self.showButton.toggle()
                                                return
                                            }
                                            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                            
                                            let fileName = url.appendingPathComponent("myRcd.m4a")
                                            
                                            let settings = [
                                                
                                                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                                                AVSampleRateKey: 12000,
                                                AVNumberOfChannelsKey : 1,
                                                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                                            ]
                                            
                                            self.recorder = try AVAudioRecorder(url: fileName, settings: settings)
                                            self.recorder.record()
                                            self.record.toggle()
                                            self.showButton.toggle()
                                        }catch{
                                            print(error.localizedDescription)
                                        }
                                    }){
                                        VStack{
                                            Image("redButton").resizable().frame(width:180.0 , height: 160.0)
                                        }
                                    }
                                    .padding(.vertical, 25)
                                    
                                    if showButton{
                                        Button(action:{
                                            self.audios.removeAll()
                                            self.recorder.stop()
                                            self.record.toggle()
                                            self.showButton.toggle()
                                            self.showingAlert.toggle()
                                        }){
                                            VStack{
                                                ZStack{
                                                    Image(systemName: "stop.circle")
                                                    .imageScale(.large)
                                                }
                                                Text("Cancelar")
                                                    .font(.subheadline)
                                                    .foregroundColor(Color.black)
                                            }
                                            
                                        }.padding(.vertical, 5)
                                    }
                                    
                                }
                                .navigationBarTitle("Perfect Melody")
                                .font(.largeTitle)

                    }
                    ZStack{
                        HStack{
                            Spacer()
                            VStack{
                                HStack{
                                    Button(action:{
                                        withAnimation{
                                            self.isPresented.toggle()
                                        }
                                        if(self.player.isPlaying){
                                            self.stopPlayback()
                                        }
                                    },label: {
                                        Text("Dismiss")
                                            .font(.headline)
                                            .foregroundColor(.black)
                                    })
                                    Spacer()
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.black)
                                        .onTapGesture {
                                            withAnimation{
                                                self.isPresented.toggle()
                                            }
//                                            if(self.player.isPlaying){
//                                                self.stopPlayback()
//                                            }
                                    }
                                }
                                .padding(.top,UIApplication.shared.windows.filter{$0.isKeyWindow}.first?.safeAreaInsets.top)
                                Spacer()
                                HStack{
                                    Button(action:{
                                        print("Reproduce")
                                        print(self.audios[0].relativeString)
                                        self.startPlayback(audio: self.audios[0])
                                    }){
                                        Image(systemName: "play.fill")
                                            .foregroundColor(.red)
                                            .frame(width:70, height: 70)
                                    }
                                    Button(action:{
                                        print("Se detiene")
                                        self.stopPlayback()
                                    }){
                                        Image(systemName:"stop.fill")
                                        .foregroundColor(.red)
                                        .frame(width:70, height: 70)
                                    }
                                }
                                ZStack(alignment: .leading){
                                    Capsule().fill(Color.black.opacity(0.08)).frame(width: 400 ,height: 8)
                                    Capsule().fill(Color.red).frame(width:self.time,height: 8)
                                }
                                Spacer()
                                HStack{
                                    Spacer()
                                    Button(action:{
                                            self.isPresented.toggle()
                                            self.showModal=true;
                                        }){
                                            Text("Enviar")
                                            .fontWeight(.bold)
                                            .font(.title)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(20)
                                            .foregroundColor(.black)
                                            .padding(10)
                                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black, lineWidth: 2))
                                    }.sheet(isPresented: self.$showModal){
                                        CoincidencesList(url: self.audios[0].absoluteURL)
                                    }
                                    Spacer()
                                    Button(action:{
                                        self.isPresented.toggle()
                                    }){
                                        Text("Intentar de Nuevo")
                                        .fontWeight(.bold)
                                        .font(.title)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(20)
                                        .foregroundColor(.black)
                                        .padding(10)
                                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black, lineWidth: 2))
                                    }
                                    Spacer()
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                    }.background(Color.white)
                    .edgesIgnoringSafeArea(.all)
                        .offset(x:0, y: self.isPresented ? 0 :
                            UIApplication.shared.windows.filter{$0.isKeyWindow}.first?.frame.height ?? 0)
            }
            .alert(isPresented: self.$alert, content: {
                Alert(title:Text("Error"), message: Text("Enable Access"))
            })
            .onAppear{
                do{
                    self.session = AVAudioSession.sharedInstance()
                    try self.session.setCategory(.playAndRecord)
                    
                    self.session.requestRecordPermission{
                        (status) in
                        if !status{
                            self.alert.toggle()
                        }
                        else{
                            self.getAudios()
                        }
                    }
                }catch{
                    print(error.localizedDescription)
                }
            }
        }
        
        func getAudios() {
            do{
                let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let result = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
                
                self.audios.removeAll()
                
                self.audios.append(contentsOf: result)
                
            }catch{
                print(error.localizedDescription)
            }
        }
        
        func startPlayback(audio: URL){
            do{
                player = try AVAudioPlayer(contentsOf: audio)
                player?.play()
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true){_ in
                    let value  = self.player.currentTime / self.player.duration
                    
                    self.time = 400 * CGFloat(value)
                }
            }catch{
                print(error.localizedDescription)
            }
        }
        
        func stopPlayback(){
            player.stop()
        }
        
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Response: Codable{
    var status_code: Int
    var body: [Post]
}

class ApiRequest{
    
//    @State var audios: [URL] = []
    var urlAudio: URL
    init(url: URL){
        self.urlAudio = url
    }
//    func getAudiosToSend() {
//        do{
//            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            let result = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
//
//            self.audios.removeAll()
//
//            self.audios.append(contentsOf: result)
//
//        }catch{
//            print(error.localizedDescription)
//        }
//    }
    
    func getConincidences() {
        
        print(urlAudio)
        if let hummingData = try? Data(contentsOf: urlAudio) {
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(hummingData, withName: "humming", fileName: "myRcd.m4a",mimeType: "audio/m4a")
            }, to: "http://18.191.176.24/api/ranking", headers: ["X-Perfect-Melody-Token":"xma1lhVnlBe9aruYvZY4W8q1ruSmpshmMwLTYFohB9mrOlkCdI" ]).responseDecodable(of: Response.self) { response in
                    debugPrint(response) 
                }
            
        }
        
        
    }
        
    func getPosts(completion: @escaping (Response) -> ()){
//        self.getAudiosToSend()
        guard let url = URL(string: "http://18.191.176.24/api/ranking") else {return}
        let boundary = "---011000010111000001101001"
        let startBoundary = "--\(boundary)"
        let endingBoundary = "--\(boundary)--"
        
//        print("URL Audio")
//        print(self.urlAudio)
        
        var body = Data()
        
        let recordingData: Data? = try? Data(contentsOf: self.urlAudio)
        let urlStr = "\(self.urlAudio)"
        let pathArr = urlStr.components(separatedBy: "/")
        let fileName = pathArr.last
        var header = "Content-Disposition: form-data; name=\"\(fileName)\"; filename=\"\(self.urlAudio)\"\r\n"

        print("header")
        print(header)
        
        body.append(("\(startBoundary)\r\n" as String).data(using:.utf8)!)
        body.append((header as String).data(using:.utf8)!)
        body.append(("Content-Type: application/octet-stream\r\n\r\n" as String).data(using:.utf8)!)
        body.append(recordingData!)
        body.append(("\r\n\(endingBoundary)\r\n" as String).data(using:.utf8)!)

        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("xma1lhVnlBe9aruYvZY4W8q1ruSmpshmMwLTYFohB9mrOlkCdI", forHTTPHeaderField: "X-Perfect-Melody-Token")
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/x-www-form-urlencoded",forHTTPHeaderField: "Accept")
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("multipart/form-data", forHTTPHeaderField: "Accept")
        
        print("body")
        print(body)
        print("request")
        print(request.allHTTPHeaderFields)

        URLSession.shared.dataTask(with: request){ (data,response,error) in
            guard let data = data else {
                print("No data in response: \(error?.localizedDescription ?? "Unkown error").")
                return
            }
            
            if let decodedOrder = try? JSONDecoder().decode(Response.self, from: data){
                DispatchQueue.main.async {
                    completion(decodedOrder)
                }
            }
        }
        .resume()
    }
}

struct CoincidencesList: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @State var data: [Post] = []
    var url: URL
    
    var body: some View{
        NavigationView{
            List(data){ post in
                VStack(alignment:.leading){
                    VStack(alignment:.leading){
                        Text("Cancion: \(post.name)")
                        Text("Artista/Grupo: \(post.artist)")
                    }
                    HStack{
                        Image("youtube_large_icon").resizable().frame(width: 40, height: 40)
                        Spacer()
                        Image("spotify_icon").resizable().frame(width: 40, height: 40)
                        Spacer()
                        Image("soundcloud_icon").resizable().frame(width: 40, height: 40)
                    }
                }
            }
            .navigationBarTitle("Resultados")
        }
        .onAppear(){
//            ApiRequest(url: self.url).getPosts(completion: { result in
//                self.data = result.body
//            })
            ApiRequest(url: self.url).getConincidences()
        }
    }
}
