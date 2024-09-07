import SwiftUI

struct PianoView: View {
    @ObservedObject var viewModel: PianoViewModel
    let whiteKeyWidth: CGFloat = 40
    let whiteKeyHeight: CGFloat = 200
    let blackKeyWidth: CGFloat = 30
    let blackKeyHeight: CGFloat = 120
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(60...72, id: \.self) { midiNote in
                if isWhiteKey(midiNote) {
                    whiteKey(midiNote)
                }
            }
        }
        .overlay(
            HStack(spacing: 0) {
                ForEach(60...72, id: \.self) { midiNote in
                    if !isWhiteKey(midiNote) {
                        blackKey(midiNote)
                    }
                }
            }
        )
    }
    
    func isWhiteKey(_ midiNote: Int) -> Bool {
        let note = midiNote % 12
        return [0, 2, 4, 5, 7, 9, 11].contains(note)
    }
    
    func whiteKey(_ midiNote: Int) -> some View {
        let activeNote = viewModel.notes.first(where: { $0.pitch == midiNote && viewModel.isNoteActive($0) })
        return Rectangle()
            .fill(activeNote != nil ? Color.blue : Color.white)
            .frame(width: whiteKeyWidth, height: whiteKeyHeight)
            .border(Color.black, width: 1)
    }
    
    func blackKey(_ midiNote: Int) -> some View {
        let activeNote = viewModel.notes.first(where: { $0.pitch == midiNote && viewModel.isNoteActive($0) })
        return Rectangle()
            .fill(activeNote != nil ? Color.blue : Color.black)
            .frame(width: blackKeyWidth, height: blackKeyHeight)
            .offset(x: -blackKeyWidth / 2)
    }
}

struct PianoView_Previews: PreviewProvider {
    static var previews: some View {
        PianoView(viewModel: PianoViewModel())
    }
}
