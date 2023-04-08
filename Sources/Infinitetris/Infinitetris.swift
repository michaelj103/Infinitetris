import TetrominoCore
import Dispatch

@main
public struct Infinitetris {

    public static func main() {
        let size = Size(width: 10, height: 20)
#if os(Linux)
        let runner = Runner(size, animator: LEDAnimator())
        runner.run()
#else
        let runner = Runner(size, animator: GIFAnimator())
        runner.runFinite(10) {
            exit(0)
        }
#endif
        
//        let runner = Runner(size, animator: NopAnimator(), randomSource: RandomSource(seed: 7161991))
//        runner.run()
        
        dispatchMain()
    }
    
    private struct DefaultPieceIdentifier: PieceIdentifying {
        func getPiece(for id: Int) -> Piece {
            return Piece.defaultPieces[id]
        }
    }
}
