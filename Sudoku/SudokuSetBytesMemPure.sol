// AGPL-3.0-only
// NON-AI AGPL-3.0-only

pragma solidity ^0.8.17;

import "hardhat/console.sol";
//  import "woke/console.sol";
// import "./LibrarySet.sol";

library SetSudokuLib {
  uint constant INDEX = 9;

  struct Set {
    bytes1[9]  values;
  }

  error duplicateError(bytes1, bytes32 , bytes4);
  error duplicateError2(bytes1, bytes4);

  function insert(Set memory set, uint key, bytes32 action, bytes1 cellValue) internal pure {
    bytes1 test = contains(set, cellValue);
    if (contains(set, cellValue) == hex'01') revert duplicateError(bytes1(uint8(cellValue) + 1), action, hex'DEADBEEF');
    set.values[uint(uint8(cellValue))] = hex'01';
  }

  function contains(Set memory set, bytes1 cellValue) internal pure returns(bytes1) {
    return set.values[uint(uint8(cellValue))];
  }

   function reset(Set storage set) internal {
      delete set.values;
    }
}

contract Sudoku {
  using SetSudokuLib for SetSudokuLib.Set;
  
  uint constant INDEX = 9;
  
  SetSudokuLib.Set seenList;
  event Log(string indexed message);

  function isValid(uint[INDEX][INDEX] calldata sudokuBoard) external pure returns (uint) {
    // TODO
    // if (!isValidRowsAndColumns(sudokuBoard)) {
    //     return false;
    // }

    uint cellValue;

    SetSudokuLib.Set memory rowList;
    SetSudokuLib.Set memory colList;
    SetSudokuLib.Set memory blockList;
  
    for (uint r = 0; r < 9; r++) {
        for(uint c = 0; c < 9; c++) { // replacie with function insertBlockInner
            cellValue = sudokuBoard[r][c];
            if(cellValue != 0) {
                cellValue = sudokuBoard[r][c] -1; // index
                if(rowList.values[cellValue] == hex'01') {
                    revert SetSudokuLib.duplicateError2(bytes1(uint8(cellValue)+1), hex'DEADBEEF') ;
                }
                rowList.values[cellValue] = hex'01';
            }

            cellValue = sudokuBoard[c][r]; // index
            if(cellValue != 0) {
                cellValue -= 1;
                if(colList.values[cellValue] == hex'01') {
                    revert SetSudokuLib.duplicateError2(bytes1(uint8(cellValue) +1),  hex'FDFDFDFD') ;
                }
                colList.values[cellValue] = hex'01';
            }

            cellValue = sudokuBoard[3* (r / 3 )+ c/3][3*(r%3)+(c%3)];
            if(cellValue != 0) {
                cellValue -= 1;
                if(blockList.values[cellValue] == hex'01') {
                    revert SetSudokuLib.duplicateError2(bytes1(uint8(cellValue) +1), hex'BEBEBEBE') ;
                }
                blockList.values[cellValue] = hex'01';
            }
        }

        delete rowList.values;
        delete colList.values;
        delete blockList.values;
    }

    return 2; // true
  }

  function isValidBlocks(uint[INDEX][INDEX] calldata sudokuBoard) external pure {
    SetSudokuLib.Set memory seenListMem;
    uint blockNumber = 0;
    uint count = 0; // for dev. can be removed
    bytes1 cellValue;

    for (uint rowBlock = 0; rowBlock < 9; rowBlock += 3) {
      for (uint colBlock = 0; colBlock < 9; colBlock += 3) {
        for (uint miniRow = rowBlock; miniRow < rowBlock + 3; miniRow++) {
          for (uint miniCol = colBlock; miniCol < colBlock + 3; miniCol++) {
            cellValue = bytes1(uint8(sudokuBoard[miniRow][miniCol]));
            if (cellValue == 0) {
              continue;
            }
            seenListMem.insert(count++, "blocks", bytes1(uint8(cellValue) - 1));
          }
        }
        count = 0; // for dev. can be removed
        blockNumber++;
        delete seenListMem.values;
      }
    }
    // emit Log("blocks");
  }

  function isValidRows(uint[9][9] calldata sudokuBoard) external pure returns (uint) {
    // _flag = flag;
    SetSudokuLib.Set memory seenListMem;

    for (uint row = 0; row < 9; row++) {
      insertListInner(seenListMem, sudokuBoard, "rows", row);
    }
    // emit Log("row");
    return 2;
  }

  function isValidColumns(uint[9][9] calldata sudokuBoard) external pure returns (uint) {
    SetSudokuLib.Set memory seenListMem;

    for (uint col = 0; col < 9; col++) {
        insertListInner(seenListMem, sudokuBoard, "cols", col);
    }
      // emit Log("Cols");
      return 2;
  }

  function insertListInner(SetSudokuLib.Set memory seenListMem, uint[9][9] calldata board, bytes32 note, uint position) private pure {
    bytes1 cellValue;

    for (uint j = 0; j< 9; j++) {
      if (note == "rows") {
        cellValue = bytes1(uint8(board[position][j]));
      }
      else { //col
        cellValue = bytes1(uint8(board[j][position])) ;
      }
      if(cellValue == 0x0) { // empty cell
        continue;
      }
      require(cellValue < bytes1(uint8(0xA)), "number too high");
      seenListMem.insert(j, note, bytes1(uint8(cellValue) - 1));
    }

      delete seenListMem.values;
  }

  // function isValidRowsAndColumns(int8[9][9] calldata sudokuBoard) {
  //   // TODO
  //   //rows
  //   //cols
  // }
}
