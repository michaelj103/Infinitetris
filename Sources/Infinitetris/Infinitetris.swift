import TetrominoCore

@main
public struct Infinitetris {

    public static func main() {
        let size = Size(width: 10, height: 20)
        let solver = MoveSolver(size)
//        solver.randomGenerator = LinearCongruentialGenerator(seed: 7161991)
        let moves = solver.runUntilNextClear(2)
        
        if moves.count > 0 {
            let output = PiecePrinter.GenerateString(size, placements: moves, store: DefaultPieceIdentifier())
            print(output)
        }
        print(moves.last ?? "failed")
        
        solver.board.clearCompletedRows()
        let moves2 = solver.runUntilNextClear(4)
        if moves2.count > 0 {
            let output2 = PiecePrinter.GenerateString(size, placements: moves2, store: DefaultPieceIdentifier(), board: solver.board)
            print(output2)
        }
        
        solver.board.clearCompletedRows()
        let moves3 = solver.runUntilNextClear(3)
        if moves3.count > 0 {
            let output3 = PiecePrinter.GenerateString(size, placements: moves3, store: DefaultPieceIdentifier(), board: solver.board)
            print(output3)
        }
    }
    
    private struct DefaultPieceIdentifier: PieceIdentifying {
        func getPiece(for id: Int) -> Piece {
            return Piece.defaultPieces[id]
        }
    }
}
