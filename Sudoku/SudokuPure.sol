// AGPL-3.0-only
// NON-AI AGPL-3.0-only

pragma solidity ^0.8.17;

import "hardhat/console.sol";
//  import "woke/console.sol";
// import "./LibrarySet.sol";

// interface Board {
//   function makeBoard() external pure returns (uint[][] calldata); // TODO??
// }


library SetSudokuLib {
  uint constant INDEX = 9;
  
  struct Set {
    bytes values;
  }

  error duplicateError(uint, bytes32 , bytes4);
  error duplicateError2(bytes1, bytes4);

  function insert(Set memory set, uint key, bytes32 action, uint cellValue) internal pure {
    if (contains(set, cellValue) == hex'01') revert duplicateError(cellValue + 1, action, hex'DEADBEEF');
      set.values[cellValue] = hex'01';
  }

  function contains(Set memory set, uint cellValue) internal pure returns(bytes1) {
    return set.values[cellValue];
  }

   function reset(Set memory set) internal pure {
      set.values = new bytes(9);
      assert(bytes9(set.values) | 0x0 == 0x0);
    }
}


contract SudokuMem {
  using SetSudokuLib for SetSudokuLib.Set;

  uint8 constant INDEX = 9;

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

    rowList.values = new bytes(9);
    colList.values = new bytes(9);
    blockList.values = new bytes(9);
   
    for (uint r = 0; r < 9; r++) {
        for(uint c = 0; c < 9; c++) {
          unchecked {
            cellValue = sudokuBoard[r][c];
          }
          require(cellValue < 10, "too high");
            if(cellValue != 0) {
              unchecked {
                cellValue -= 1;
              }
              if(rowList.contains(cellValue) == hex'01') {
                  revert SetSudokuLib.duplicateError2(bytes1(uint8(cellValue + 1)), hex'DEADBEEF') ;
              }
              rowList.insert(c, "rows", cellValue);
            }

            unchecked {
              cellValue = sudokuBoard[c][r];
            }
            require(cellValue < 10, "too high");

            if(cellValue != 0) {
              unchecked {
                cellValue -= 1;
              }
                if(colList.contains(cellValue) == hex'01') {
                    revert SetSudokuLib.duplicateError2(bytes1(uint8(cellValue + 1)),  hex'FDFDFDFD') ;
                }
                colList.insert(c, "cols", cellValue);
            }
            unchecked {
              cellValue = sudokuBoard[3* (r / 3 )+ c/3][3*(r%3)+(c%3)];
            }

            require(cellValue < 10, "too high");
            if(cellValue != 0) {
              unchecked {
                cellValue -= 1;
              }
                if(blockList.contains(cellValue) == hex'01') {
                    revert SetSudokuLib.duplicateError2(bytes1(uint8(cellValue + 1)), hex'BEBEBEBE') ;
                }
                blockList.insert(c, "block", cellValue);
            }
        }

        assembly {
          mstore(add(mload(rowList), 0x20), 0x0)
          mstore(add(mload(colList), 32), 0)
          mstore(add(mload(blockList), 32), 0)
        }

        assert(bytes9(rowList.values) | 0 == 0);
        assert(bytes9(colList.values) | 0 == 0);
        assert(bytes9(blockList.values) | 0 == 0);
    }

    return 2; // true
  }

  function isValidBlocks(uint[INDEX][INDEX] calldata sudokuBoard) external pure returns (uint) {
    SetSudokuLib.Set memory seenListMem;
    seenListMem.values = new bytes(9);
    uint _rowBlock;
    uint _colBlock;
    uint cellValue;
    uint blockNumber = 0;

    for (uint rowBlock = 0; rowBlock < 9; rowBlock += 3) {
      for (uint colBlock = 0; colBlock < 9; colBlock += 3) {
        unchecked {
          _rowBlock = rowBlock + 3;
          _colBlock = colBlock + 3;
        }
        for (uint miniRow = rowBlock; miniRow < _rowBlock; miniRow++) {
          for (uint miniCol = colBlock; miniCol < _colBlock; miniCol++) {
            unchecked {
              cellValue = sudokuBoard[miniRow][miniCol];
            }
            if (cellValue == 0) {
              continue;
            }
            require(cellValue < 10, "number too high");
            seenListMem.insert(blockNumber, "blocks", cellValue -1);
            
          }
        }
        blockNumber++;
        seenListMem.reset();
      }
    }

    // emit Log("blocks");
    return 2;
  }

  function isValidRows(uint[9][9] calldata sudokuBoard) external pure returns (uint) {
    SetSudokuLib.Set memory seenListMem;
    seenListMem.values = new bytes(9);
  
    for (uint row = 0; row < 9; row++) {
      insertListInner(seenListMem, sudokuBoard, "rows", row); // execution cost	36468 gas
    }
    // emit Log("row");
    return 2;
  }

  function isValidColumns(uint[9][9] calldata sudokuBoard) external pure returns (uint) {
    SetSudokuLib.Set memory seenListMem;
    seenListMem.values = new bytes(9);
    
    for (uint i = 0; i < 9; i++) {
        insertListInner(seenListMem, sudokuBoard, "cols", i);
    }
    return 2;
  }

//   function insertBlockInner() {
//   }

  function insertListInner(SetSudokuLib.Set memory seenListMem, uint[9][9] calldata board, bytes32 note, uint position) private pure {
    uint cellValue;

    unchecked {
      for (uint j = 0; j< 9; j++) {
        if (note == "rows") {
          cellValue = board[position][j];
        }
        else { //col
          cellValue = board[j][position] ;
        }
        if(cellValue == 0) {
          continue;
        }
        require(cellValue < 10, "number too high");
        
        seenListMem.insert(j, note, cellValue - 1);
      }
    }

    assertTest(seenListMem);
  }

  function assertTest(SetSudokuLib.Set memory seen) private pure {
    seen.reset();
  }

  // function isValidRowsAndColumns(int8[9][9] calldata sudokuBoard) {
  //   // TODO
  //   //rows
  //   //cols
  // }
}

