import TetrominoCore

@main
public struct Infinitetris {

    public static func main() {
        let size = Size(width: 10, height: 20)
        let solver = MoveSolver(size)
        solver.randomGenerator = LinearCongruentialGenerator(seed: 7161991)
        let moves = solver.runUntilNextClear(1)
        
        if moves.count > 0 {
            let output = PiecePrinter.GenerateString(size, placements: moves, store: DefaultPieceIdentifier())
            print(output)
        }
        print(moves.last ?? "failed")
    }
    
    private struct DefaultPieceIdentifier: PieceIdentifying {
        func getPiece(for id: Int) -> Piece {
            return Piece.defaultPieces[id]
        }
    }
}
