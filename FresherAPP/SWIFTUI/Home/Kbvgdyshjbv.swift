 
import Foundation
import SwiftUI

struct Kbvgdyshjbv: View {
    
    @ObservedObject var bvhsjbv: Btsgjdhbv = Btsgjdhbv()
    @State var piohsdb: Bool = true
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.4), Color.purple.opacity(0.4)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            if let url = URL(string: UserDataManager.njwhbueihjskbdvshjbv.jhgb ?? "") {
              

                Nbvsdjhbv(gggsdhvc: $piohsdb) {
                    Nmnbgvbjnsd(url: url, webViewStateModel: bvhsjbv)
                        .background(Color.black.ignoresSafeArea())
                        .edgesIgnoringSafeArea(.bottom)
                        .onAppear{
                           
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0){
                                piohsdb = false

                            }
                            
                        }
                }
                        } else {
                            
                            ZStack{
                                Nbvsdjhbv(gggsdhvc: $piohsdb) {
                                    Nmnbgvbjnsd(url:  URL(string: bvhsjbv.vwuhbvuwevb)!, webViewStateModel: bvhsjbv) .background(Color.black.ignoresSafeArea()).edgesIgnoringSafeArea(.bottom).onAppear{
                                        
                                    }
                                }
                                
                            }.onAppear{
                               
                                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0){
                                    piohsdb = false
                                }
                            }
                                   
                               
                           
                        }
        }
    }
    
}

class UserDataManager {
    static let njwhbueihjskbdvshjbv = UserDataManager()
    
    var jhgb: String?
    var nbuhb: String?
    var bvygh: String?
}
