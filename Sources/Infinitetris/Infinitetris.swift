import TetrominoCore
import Dispatch

@main
public struct Infinitetris {

    public static func main() {
        let size = Size(width: 10, height: 20)
#if os(Linux)
        
#else
        let runner = Runner(size, animator: GIFAnimator())
        runner.runFinite(10) {
            exit(0)
        }
#endif
        dispatchMain()
    }
    
    private struct DefaultPieceIdentifier: PieceIdentifying {
        func getPiece(for id: Int) -> Piece {
            return Piece.defaultPieces[id]
        }
    }
}
