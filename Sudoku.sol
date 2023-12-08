// AGPL-3.0-only
// NON-AI AGPL-3.0-only

pragma solidity ^0.8.17;

// import "hardhat/console.sol";
import "woke/console.sol";

contract Sudoku {
  // int8[9][9] public board;

  uint8 constant index = 9;
  struct  Set  {
    int8[index] values;
    mapping (int8 => bool) contains;
  }
  bool flag;

  // Set seenBlock;
  Set[index]  seenBlock;
  // Set[index] seenRows; for rowsandcolumns todo or just use rowList
  // Set[index] seenCols; for rowsandcolumns todo or just use columnSet(less gas??)
  Set rowList;
  // Set rowList_;
  Set columnSet;

  function isValid(int8[index][index] calldata sudokuBoard) public returns (bool) {
    // TODO
    // if (!isValidRowsAndColumns(sudokuBoard)) {
    //     return false;
    // }

    if (!isValidRows(sudokuBoard)) {
      console.log("false row");
      return flag;
    }

    if (!isValidColumns(sudokuBoard)) {
      console.log("false col");
      return false;
    }

    if (!isValidBlocks(sudokuBoard)) {
      console.log("false block");
      return false;
    }
    console.log("true");
    return true;
  }

  function isValidBlocks(int8[index][index] calldata sudokuBoard) public returns (bool) {
      // Set[9] storage _seenBlock = seenBlock;
      uint8 blockNumber = 0;
      uint8 count = 0; // for dev. can be removed

    for (uint8 rowBlock = 0; rowBlock < 9; rowBlock += 3) {
      for (uint8 colBlock = 0; colBlock < 9; colBlock += 3) {
//         Set storage _seenBlock = seenBlock;
        // iterate over the cells in each block.
        for (uint8 miniRow = rowBlock; miniRow < rowBlock + 3; miniRow++) {
          for (uint8 miniCol = colBlock; miniCol < colBlock + 3; miniCol++) {
            int8 cellValue = sudokuBoard[miniRow][miniCol];
            // continue if no value assigned to cell
            if (cellValue == -1) {
              seenBlock[blockNumber].values[count++] = cellValue; // for dev. can be removed
              // continue;
            }
            else if (cellValue < 1 || cellValue > 9) {
              console.log("faalse");
              resetBlock(seenBlock);
              return false;
            }
            else if (seenBlock[blockNumber].contains[cellValue]) {
              console.log("false", blockNumber, miniRow, miniCol);
              resetBlock(seenBlock);
              return false;
            }
            else {
              seenBlock[blockNumber].values[count++] = cellValue; // for dev. can be removed
              seenBlock[blockNumber].contains[cellValue] = true;
            }
//                 console.log("blockNumber", blockNumber);
          }
        }
        count = 0; // for dev. can be removed
        blockNumber++;
      }
    }

    // reset mapping in struct array
    resetBlock(seenBlock);

    console.log("true");
    return true;
  }

  function isValidRows(int8[9][9] calldata sudokuBoard) public returns(bool _flag) {
    _flag = false;

   for (uint8 row = 0; row < 9; row++) {
      for (uint8 i = 0; i < 9; i++) {
        int8 cellValue = sudokuBoard[row][i];

        if (cellValue == -1) {
          rowList.values[i] = cellValue; // for dev. can be removed
          // continue;
        }
        else if (cellValue < 1 || cellValue > 9) {
          console.log("false 1");
          // _rowList = _rowListEmpty;
          // reset mapping in struct
          reset(rowList);
          return _flag;
        }
        else if (rowList.contains[cellValue]) {
          console.log("false2", row, i);
          reset(rowList);
          return _flag;
        }
        // add current cell value to row mapping value array.
        else {
          rowList.contains[cellValue] = true;
          rowList.values[i] = cellValue;
        }
          // _rowList = rowList_;
      }
      reset(rowList);
    }

    console.log("true!!");
    _flag = true;
    return _flag;
  }

  function isValidColumns(int8[9][9] calldata sudokuBoard) public returns (bool _flag) {
    // console.log(sudokuBoard.length);
    // Set storage _columnSet = columnSet;
    _flag = false;

    for (uint8 col = 0; col < 9; col++) {
      for (uint8 i = 0; i < 9; i++) {
        int8 cellValue = sudokuBoard[i][col];
        if (cellValue == -1) {
          columnSet.values[i] = cellValue; // for dev. can be removed
            // continue;
        }
        else if (cellValue < 1 || cellValue > 9) {
          console.log("false 1");
          reset(columnSet);
          return _flag;
        }
        else if (columnSet.contains[cellValue]) {
          console.log("false2", i, col);
          reset(columnSet);
          return _flag;
        }
        else {
          columnSet.contains[cellValue] = true;
          columnSet.values[i] = cellValue;
        }
      }

      // delete _columnSet;
      // for(int8 j = 1; j <= 9; j++) {
      //     if (_columnSet.contains[j]) {
      //         _columnSet.contains[j] = false;
      //     }
      //     _columnSet.values[uint8(j) - 1] = 0;
      // }
      reset(columnSet);
      console.log("true!!");
      _flag = true;
      return _flag;
    }
  }

  // function isValidRowsAndColumns(int8[9][9] calldata sudokuBoard) {
  //   // TODO
  //   //rows
  //   //cols
  // }

  function resetBlock(Set[index] storage zeroBlock) internal {
    for(uint8 j = 0; j < 9; j++) {
      reset(zeroBlock[j]);
    }
  }

  function reset(Set storage zeroSet) internal {
    // reset mapping in struct
    for(int8 j = 1; j <= 9; j++) {
        delete zeroSet.contains[j];
    }
    delete zeroSet.values;
  }
}
