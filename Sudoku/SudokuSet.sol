// AGPL-3.0-only
// NON-AI AGPL-3.0-only

pragma solidity ^0.8.17;

// import "hardhat/console.sol";
 import "woke/console.sol";

contract Sudoku {
  // int8[9][9] public board;

  uint8 constant INDEX = 9;
  struct  Set  {
    uint8[INDEX] values;
    mapping (uint8 => uint8) contains;
  }
  uint8 flag;
  Set seenList;

  function isValid(uint8[INDEX][INDEX] memory sudokuBoard) public returns (uint8) {
    // TODO
    // if (!isValidRowsAndColumns(sudokuBoard)) {
    //     return false;
    // }

    if (isValidRows(sudokuBoard) == 0) {
      console.log("false row");
      return flag;
    }

    if (isValidColumns(sudokuBoard) == 0) {
      console.log("false col");
      return 0;
    }

    if (isValidBlocks(sudokuBoard) == 0) {
      console.log("false block");
      return 0;
    }
    console.log("true");
    return 1;
  }

  function isValidBlocks(uint8[INDEX][INDEX] memory sudokuBoard) public returns (uint8) {
      // Set[9] storage _seenBlock = seenBlock;
      uint8 blockNumber = 0;
      uint8 count = 0; // for dev. can be removed

    for (uint8 rowBlock = 0; rowBlock < 9; rowBlock += 3) {
      for (uint8 colBlock = 0; colBlock < 9; colBlock += 3) {
//         Set storage _seenBlock = seenBlock;
        // iterate over the cells in each block.
        for (uint8 miniRow = rowBlock; miniRow < rowBlock + 3; miniRow++) {
          for (uint8 miniCol = colBlock; miniCol < colBlock + 3; miniCol++) {
            uint8 cellValue = sudokuBoard[miniRow][miniCol];
            // continue if no value assigned to cell
            if (cellValue == 0) {
              seenList.values[count++] = cellValue; // for dev. can be removed
              // continue;
            }
            else if (cellValue < 1 || cellValue > 9) {
              console.log("faalse");
              reset();
              return 0;
            }
            else if (seenList.contains[cellValue] == 1) {
              console.log("false", blockNumber, miniRow, miniCol);
              reset();
              return 0;
            }
            else {
              seenList.values[count++] = cellValue; // for dev. can be removed
              seenList.contains[cellValue] = 1;
            }
            // else if (seenBlock[blockNumber].contains[cellValue]) {
            //   console.log("false", blockNumber, miniRow, miniCol);
            //   resetBlock(seenBlock);
            //   return false;
            // }
            // else {
            //   seenBlock[blockNumber].values[count++] = cellValue; // for dev. can be removed
            //   seenBlock[blockNumber].contains[cellValue] = true;
            // }
//                 console.log("blockNumber", blockNumber);
          }
        }
        count = 0; // for dev. can be removed
        blockNumber++;
        reset();
      }
    }

    // reset mapping in struct array
    // delete seenList;
    reset();

    console.log("true");
    return 1;
  }

  function isValidRows(uint8[9][9] memory sudokuBoard) public returns(uint8 _flag) {
    _flag = flag;

   for (uint8 row = 0; row < 9; row++) {
      for (uint8 i = 0; i < 9; i++) {
        uint8 cellValue = sudokuBoard[row][i];

        if (cellValue == 0) {
          seenList.values[i] = cellValue; // for dev. can be removed
          // continue;
        }
        else if (cellValue < 1 || cellValue > 9) {
          console.log("false 1");
          // _rowList = _rowListEmpty;
          // reset mapping in struct
          reset();
          return _flag;
        }
        else if (seenList.contains[cellValue] == 1) {
          console.log("false2", row, i);
          reset();
          return _flag;
        }
        // add current cell value to row mapping value array.
        else {
          seenList.contains[cellValue] = 1;
          seenList.values[i] = cellValue;
        }
          // _rowList = rowList_;
      }
      // delete seenList;
      reset();
    }

    console.log("true!!");
    _flag = 1;
    return _flag;
  }

  function isValidColumns(uint8[9][9] memory sudokuBoard) public returns (uint8 _flag) {
    // console.log(sudokuBoard.length);
    // Set storage _columnSet = columnSet;
    _flag = 0;

    for (uint8 col = 0; col < 9; col++) {
      for (uint8 i = 0; i < 9; i++) {
        uint8 cellValue = sudokuBoard[i][col];
        if (cellValue == 0) {
          seenList.values[i] = cellValue; // for dev. can be removed
            // continue;
        }
        else if (cellValue < 1 || cellValue > 9) {
          console.log("false 1");
          reset();
          return _flag;
        }
        else if (seenList.contains[cellValue] == 1) {
          console.log("false2", i, col);
          reset();
          return _flag;
        }
        else {
          seenList.contains[cellValue] = 1;
          seenList.values[i] = cellValue;
        }
      }
      reset();
    }
    // delete _columnSet;
      // for(int8 j = 1; j <= 9; j++) {
      //     if (_columnSet.contains[j]) {
      //         _columnSet.contains[j] = false;
      //     }
      //     _columnSet.values[uint8(j) - 1] = 0;
      // }
      // delete seenList;
      reset();
      console.log("true!!");
      _flag = 1;
      return _flag;
  }

  // function isValidRowsAndColumns(int8[9][9] calldata sudokuBoard) {
  //   // TODO
  //   //rows
  //   //cols
  // }

//   function resetBlock(Set[index] storage zeroBlock) internal {
//     for(uint8 j = 0; j < 9; j++) {
//       reset(zeroBlock[j]);
//     }
//   }
  // reset values
  function reset() internal {
    delete seenList;
    
    for(uint8 j = 1; j <= 9; j++) {
        delete seenList.contains[j];
    }
    // delete zeroSet.values;
  }
}
