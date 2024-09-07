import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PianoViewModel()
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            Text("Piano Visualization")
                .font(.largeTitle)
            
            if viewModel.notes.isEmpty {
                Text("No notes loaded")
                    .foregroundColor(.red)
            } else {
                PianoView(viewModel: viewModel)
            }
            
            HStack {
                Button("Load MIDI") {
                    do {
                        try viewModel.loadMidiFile(named: "Mark-Northam-Married-Life-From-Up")
                        errorMessage = nil
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
                Button("Start") {
                    viewModel.start()
                }
                Button("Stop") {
                    viewModel.stop()
                }
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            do {
                try viewModel.loadMidiFile(named: "Mark-Northam-Married-Life-From-Up")
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
