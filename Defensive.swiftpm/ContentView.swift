import SwiftUI
import WebKit

struct Item: Identifiable {
    var id = UUID()
    var name: String
    var info: Info?
    var isChecked: Bool = false

    struct Info {
        enum InfoData {
            case url(URL)
            case string(String)
        }
        let data: InfoData
    }
}

struct ContentView: View {
    private let webView = WKWebView()
    @State private var urlString = ""
    @State private var isChecking = true
    @State private var modalText = ""
    @State private var showModal = false
    @State private var items = [
        Item(name: "iOS Version: \(UIDevice.current.systemVersion) \n(Good if 18.4 / 17.7.6 / 16.7.11 / 15.8.4)", 
             info: Item.Info(data: Item.Info.InfoData.url(URL(string: "https://support.apple.com/en-us/100100")!)), 
             isChecked: true),
        Item(name: "Swift Playgrounds v4.6.3"),
        Item(name: "Defensive Security Browser v0.1"),
        Item(name: "Domain Name (whois)",
             info: Item.Info(data: Item.Info.InfoData.string("whois information here"))),
        Item(name: "HTTPS certificate: chain of trust")
    ]
    
    var body: some View {
        VStack {
            TextField("Search or enter URL", text: $urlString, onCommit: startChecking)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.URL)
                .padding()
            ZStack {
                WebView(webView: webView)
                if isChecking {
                    List {
                        ForEach($items) { $item in
                            HStack {
                                Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                                    .foregroundColor(item.isChecked ? .green : .gray)
                                Toggle(isOn: $item.isChecked) {
                                    Text(item.name)
                                        .multilineTextAlignment(.leading)
                                }
                                .foregroundColor(item.isChecked ? .black : .red)
                                .tint(.green)
                                .toggleStyle(.button)
                                Spacer()
                                if let info = item.info {
                                    Button(action: {
                                        switch info.data {
                                        case .url(let url):
                                             UIApplication.shared.open(url)
                                        case .string(let string):
                                            modalText = string
                                            showModal = true
                                        }
                                    }) {
                                        Image(systemName: "info.circle")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $showModal) {
                        ModalView(text: $modalText)
                    }
                    Button("Go") {
                        isChecking = false
                        loadURL()
                    }
                    .tint(.green)
                    .disabled(!allItemsChecked())
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
    
    private func startChecking() {
        isChecking = true
    }

    private func allItemsChecked() -> Bool {
        return items.allSatisfy { $0.isChecked }
    }

    private func loadURL() {
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
}

struct ModalView: View {
    @Binding var text: String
    var body: some View {
        Text(text)
    }
}
