//
//  ContentView.swift
//  iospayment
//
//  Created by Takahiko Funakubo on 2023/05/15.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    
    @ObservedObject var storeManager = StoreManager()
    @State private var selectedProduct = 0
    
    init() {
        SKPaymentQueue.default().add(storeManager)
    }
    var body: some View {
        VStack {
            Spacer()
            Picker(selection: $selectedProduct, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
                if (storeManager.products.isEmpty) {
                    Text("商品を読み込み中です・・").tag(0)
                } else {
                    ForEach(Array(storeManager.products.enumerated()), id: \.element) { index, product in
                        Text(product.localizedTitle).tag(index)
                    }
                }
            }
            Button(action: {
                storeManager.purchaseProduct(storeManager.products[selectedProduct])
            }) {
                if (storeManager.status == StoreManager.Status.Normal) {
                    Text("購入")
                } else {
                    Text("購入中・・")
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .font(.body.bold())
            .clipShape(Capsule())
            Spacer()
            ScrollView {
                Text(storeManager.receipt)
                    .font(.caption)
            }
            Spacer()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
