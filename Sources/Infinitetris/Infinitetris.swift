import TetrominoCore

@main
public struct Infinitetris {

    public static func main() {
        let size = Size(width: 10, height: 20)
        let runner = Runner(size, animator: GIFAnimator())
        runner.run(10)
    }
    
    private struct DefaultPieceIdentifier: PieceIdentifying {
        func getPiece(for id: Int) -> Piece {
            return Piece.defaultPieces[id]
        }
    }
}
