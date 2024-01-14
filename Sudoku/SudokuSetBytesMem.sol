// SPDX-License-Identifier: NON-AI AGPL-3.0-only
// AGPL-3.0-only
// NON-AI AGPL-3.0-only

pragma solidity ^0.8.17;

import "hardhat/console.sol";
//  import "woke/console.sol";
// import "./LibrarySet.sol";

library SetSudokuLib {
  struct Set  {
    uint8[9]  values;
    mapping (bytes1 => bytes1) has;
  }

  struct Set2 {
    bytes1[9]  values;
  }

  error duplicateError(bytes1, bytes32 , bytes4);
  error duplicateError2(bytes1, bytes4);

  function insert(Set storage set, uint key, bytes32 action, bytes1 cellValue) internal {
    require(cellValue < hex'0A', "number too high");

    if (contains(set, cellValue) == hex'01') revert duplicateError(cellValue, action, hex'DEADBEEF');
    if(cellValue != 0 ) { // 
      set.has[cellValue] = hex'01';
      assert(contains(set, cellValue) == hex'01');
      // emit insertLog(msg.sender, key, cellValue);
    }
  }

  function contains(Set storage set, bytes1 cellValue) internal view returns(bytes1) {
    if(set.values.length == 0) return 0; // 
    return set.has[cellValue];// {//return 1;
  }

   function reset(Set storage set) internal {
      delete set.values;

      for(uint j = 1; j < 10; j++) {
        set.has[bytes1(uint8(j))] = hex'00';
        assert(set.has[bytes1(uint8(j))] == hex'00');
      }
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

    SetSudokuLib.Set2 memory rowList;
    SetSudokuLib.Set2 memory colList;
    SetSudokuLib.Set2 memory blockList;
   
    for (uint r = 0; r < 9; r++) {
        for(uint c = 0; c < 9; c++) { // 
            cellValue = sudokuBoard[r][c];
            require(bytes1(uint8(cellValue)) < hex'0A', "number too high");

            if(cellValue != 0) {
                cellValue = sudokuBoard[r][c] -1; // index
                if(rowList.values[cellValue] == hex'01') {
                    revert SetSudokuLib.duplicateError2(bytes1(uint8(cellValue + 1)), hex'DEADBEEF') ;
                }
                rowList.values[cellValue] = hex'01';
            }

            cellValue = sudokuBoard[c][r]; // index
            if(cellValue != 0) {
                cellValue -= 1;
                if(colList.values[cellValue] == hex'01') {
                    revert SetSudokuLib.duplicateError2(bytes1(uint8(cellValue + 1)),  hex'FDFDFDFD') ;
                }
                colList.values[cellValue] = hex'01';
            }

            cellValue = sudokuBoard[3* (r / 3) + c/3][3*(r%3)+(c%3)];
            if(cellValue != 0) {
                cellValue -= 1;
                if(blockList.values[cellValue] == hex'01') {
                    revert SetSudokuLib.duplicateError2(bytes1(uint8(cellValue + 1)), hex'BEBEBEBE') ;
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


  function isValidBlocks(uint[INDEX][INDEX] calldata sudokuBoard) public {
    uint blockNumber = 0;
    uint count = 0; // for dev. can be removed

    for (uint rowBlock = 0; rowBlock < 9; rowBlock += 3) {
      for (uint colBlock = 0; colBlock < 9; colBlock += 3) {
        for (uint miniRow = rowBlock; miniRow < rowBlock + 3; miniRow++) {
          for (uint miniCol = colBlock; miniCol < colBlock + 3; miniCol++) {
            bytes1 cellValue = bytes1(uint8(sudokuBoard[miniRow][miniCol]));
            seenList.insert(count++, "blocks", (cellValue));

          }
        }
        count = 0; // for dev. can be removed
        blockNumber++;
        assertTest();
      }
    }
    assertTest();
    // emit Log("blocks");
  }

  function isValidRows(uint[9][9] calldata sudokuBoard) public returns (uint) { // transfer seenlist
    // _flag = flag;

   for (uint row = 0; row < 9; row++) {
    insertListInner(sudokuBoard, "rows", row);
    }
    assertTest();
    // emit Log("row");
    return 2;
  }

  function isValidColumns(uint[9][9] calldata sudokuBoard) public returns (uint)  {
    for (uint i = 0; i < 9; i++) {
        insertListInner(sudokuBoard, "cols", i);
    }
      assertTest();
      // emit Log("Cols");
      return 2;
  }

  function insertListInner(uint[9][9] calldata board, bytes32 note, uint position) private { 
    bytes1 cellValue = hex'00';

    for (uint j = 0; j< 9; j++) {
      if (note == "rows") {
        cellValue = bytes1(uint8(board[position][j]));
      }
      else { 
        cellValue = bytes1(uint8(board[j][position]));
      }
        seenList.insert(j, note, cellValue);
    }

    assertTest();
  }

  function assertTest() private {
    seenList.reset();
  }

  // function isValidRowsAndColumns(int8[9][9] calldata sudokuBoard) {
  //   // TODO
  //   //rows
  //   //cols
  // }

}



