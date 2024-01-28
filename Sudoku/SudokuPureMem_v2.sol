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
    // bytes4 errorSelector = duplicateError.selector;
    // inline contain
    assembly {
    
      let result := contains(cellValue, set)
      if eq(result, hex'01') {
        let mem := mload(0x40)

        mstore(mem, hex'011d9462') // duplicateError.selector
        mstore8(add(mem, 0x23),add(cellValue, 1)) // cellvalue
        mstore(add(mem, 0x24) , action)
        mstore(add(mem, 0x44), hex'DEADBEEF')

        revert(mem, 0x64)
        }

        mstore8(add(add(mload(set), 0x20), cellValue), 1)

        function contains(_cellValue, _set) -> _result {
          let mask := 0xFF00000000000000000000000000000000000000000000000000000000000000
          _result := and(mload(add(add(mload(_set), 0x20), _cellValue)), mask)
        }
    }
  }

  // function contains(Set memory set, uint cellValue) internal pure returns(bytes1 result) {
  //  assembly {
  //    result := mload(add(add(mload(set), 0x20), cellValue))
  //  }
  //}

   function reset(Set memory set) internal pure {
      assembly {
        mstore(add(mload(set), 0x20), 0)
      }

      assert(bytes9(set.values) | 0x0 == 0x0); // gas becomes 40158 truncate?
    }
}


contract SudokuMem {
  
  using SetSudokuLib for SetSudokuLib.Set;
  
  uint8 constant INDEX = 9;
  
  // SetSudokuLib.Set seenList;
  event Log(string indexed message);


  function isValid(uint[INDEX][INDEX] calldata sudokuBoard) external pure returns (uint) {
    // TODO
    // if (!isValidRowsAndColumns(sudokuBoard)) {
    //     return false;
    // }

    SetSudokuLib.Set memory seen;
    seen.values = new bytes(32);

    // rowList.values = new bytes(9);
    // colList.values = new bytes(9);
    // blockList.values = new bytes(9);

    assembly {

    }


    uint cellValue;

    for (uint r = 0; r < 9; r++) {
        for(uint c = 0; c < 9; c++) { // replacie with function insertBlockInner
            cellValue = sudokuBoard[r][c];
            if(cellValue != 0) {
            // if(cellValue == 0) { // represnts empty cell
            //     continue;
            // }
                cellValue = sudokuBoard[r][c] -1; // index
                // if(rowList.values[cellValue] == hex'01') {
                if(seen.values[cellValue] == hex'01') {
                    revert SetSudokuLib.duplicateError2(bytes1(uint8(cellValue + 1)), hex'DEADBEEF') ;
                }
                
                // rowList.values[cellValue] = hex'01';

                // execution cost	222568 gas
                seen.insert(c, "rows", cellValue);

                // assembly {
                //   mstore(0x20, seen) // 0x80
                //   mstore(0x80, 0x20)
                //   mstore8(add(0x20, sub(cellValue, 1)), 1)
                // }
            }
        } // temp for testing. remove
    } // temp for testing. remove

    //         cellValue = sudokuBoard[c][r]; // index
    //         if(cellValue != 0) {
    //             cellValue -= 1;
    //             if(colList.values[cellValue] == hex'01') {
    //                 revert SetSudokuLib.duplicateError2(bytes1(uint8(cellValue + 1)),  hex'FDFDFDFD') ;
    //             }
    //             // colList.values[cellValue] = hex'01';
    //             colList.insert(c, "cols", cellValue);
    //         }

    //         cellValue = sudokuBoard[3* (r / 3 )+ c/3][3*(r%3)+(c%3)];
    //         // ellValue = sudokuBoard[r / 3* 3][3*(r%3)+(c%3)];
    //         if(cellValue != 0) {
    //             cellValue -= 1;
    //             //  board[3*Math.floor(i/3)+Math.floor(j/3)][3*(i%3)+(j%3)]
    //             if(blockList.values[cellValue] == hex'01') {
    //                 revert SetSudokuLib.duplicateError2(bytes1(uint8(cellValue + 1)), hex'BEBEBEBE') ;
    //             }
    //             // blockList.values[cellValue] = hex'01';
    //             blockList.insert(c, "block", cellValue);
    //         }
    //     }

        
        // assembly {

        // }

    // emit Log(hex'FADEDEAD');
    return 2; // true
  }

//   function insertBlockInner () {
        // TODO
//   }

  function isValidBlocks(uint[INDEX][INDEX] calldata sudokuBoard) external pure returns (uint) {
    SetSudokuLib.Set memory seenListMem;
    uint blockNumber = 0;
    uint count = 0; // for dev. can be removed

    seenListMem.values = new bytes(9);

    uint _rowBlock;
    uint _colBlock;

    uint cellValue;
    for (uint rowBlock = 0; rowBlock < 9; rowBlock += 3) {
      for (uint colBlock = 0; colBlock < 9; colBlock += 3) {
        _rowBlock = rowBlock + 3;
        _colBlock = colBlock + 3;
        for (uint miniRow = rowBlock; miniRow < _rowBlock; miniRow++) {
          for (uint miniCol = colBlock; miniCol < _colBlock; miniCol++) {
            cellValue = sudokuBoard[miniRow][miniCol];
            if (cellValue == 0) {
              continue;
            }
            require(cellValue < 10, "number too high");
            seenListMem.insert(count++, "blocks", cellValue -1);
            
          }
        }
        count = 0; // for dev. can be removed
        blockNumber++;

        seenListMem.reset();
      }
    }
    // emit Log("blocks");
    return 2;
  }


//   function isValidBlocksInner(uint[9][9] calldata sudokuBoard) private view {
//     // TODO
//   }

  function isValidRows(uint[9][9] calldata sudokuBoard) external pure returns (uint) { // transfer seenlist
    SetSudokuLib.Set memory seenListMem;
    seenListMem.values = new bytes(9);
  
  
    for (uint row = 0; row < 9; row++) {
      insertListInner(seenListMem, sudokuBoard, "rows", row); // execution cost	36468 gas
    }
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

  function insertListInner(SetSudokuLib.Set memory seenListMem, uint[9][9] calldata board, bytes32 note, uint position) private pure {
    uint cellValue;

    for (uint j = 0; j< 9; j++) {
      if (note == "rows") {
        cellValue = board[position][j];
      }
      else { //col
        cellValue = board[j][position] ;
      }
      if(cellValue == 0) { // empty cell
        continue;
      }
      require(cellValue < 10, "number too high");
      
      seenListMem.insert(j, note, cellValue - 1);
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
