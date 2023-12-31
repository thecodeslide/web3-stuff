// AGPL-3.0-only
// NON-AI AGPL-3.0-only

pragma solidity ^0.8.17;

import "hardhat/console.sol";
//  import "woke/console.sol";
// import "./LibrarySet.sol";

library SetSudokuLib {
//   uint8 constant INDEX = 9;
  struct Set  {
    uint8[9]  values;
    mapping (uint8 => uint8) has;
  }

  // error duplicateError(uint8, bytes4);
  // event insertLog(address indexed from, uint indexed key, uint value);

  function insert(Set storage set, uint8 key, uint8 cellValue) internal returns(uint) {
    require(cellValue < 0xA, "value too high"); // move to contract?
    // require(contains(set, cellValue) == 0, "error. duplicate.");
    
    // if(cellValue > 0 ) set.values[cellValue] = 1;
    // set.has[cellValue -1] = 1; 
    // else  {
    //   set.values[cellValue - 1] = 1; // TODO
    //   set.has[cellValue] = 1;
    // }
    if (contains(set, cellValue) == 1) return 1; //revert duplicateError(cellValue, 0xDEADBEEF);
    if(cellValue != 0 ) {
      set.has[cellValue] = 1;
      assert(contains(set, cellValue) == 1);
    }
    
    set.values[key] = cellValue;
  }

  function contains(Set storage set, uint8 cellValue) internal view returns(uint flag) {
    if(set.values.length == 0) return 0; 
    // if(set.values[set.has[key]] == 1) return 1;
    return set.has[cellValue];// {//return 1;
  }

   function reset(Set storage set) internal {
      delete set.values;

      for(uint8 j = 1; j <= 9; j++) {
        delete set.has[j];
        assert(set.has[j] == 0);
      }
    }
}

contract Sudoku {
  // int8[9][9] public board;
  using SetSudokuLib for SetSudokuLib.Set;
  uint8 constant INDEX = 9;

  SetSudokuLib.Set seenList;
  // Set seenList;
  // event Log(address sender, string action, uint8 key);
  // event LogErrorString(string message);
  // event LogPanicCode(uint panic);
  // event LogBytes(bytes data);

  function isValid(uint8[INDEX][INDEX] memory sudokuBoard) public returns (uint) {
    // TODO
    // if (!isValidRowsAndColumns(sudokuBoard)) {
    //     return false;
    // }
    

    if (isValidRows(sudokuBoard) == 1) {
      // console.log("false row");
      // return 1;
      revert("invalid row");
      // emit Log();
    }

    if (isValidColumns(sudokuBoard) == 1) {
      revert("invalid col");
    }

    if (isValidBlocks(sudokuBoard) == 1) {
      revert("invalid block");
    }
    // console.log("true");
    return 2;
  }

  function isValidBlocks(uint8[INDEX][INDEX] memory sudokuBoard) public returns (uint) {
    uint8 blockNumber = 0;
    uint8 count = 0; // for dev. can be removed

    for (uint8 rowBlock = 0; rowBlock < 9; rowBlock += 3) {
      for (uint8 colBlock = 0; colBlock < 9; colBlock += 3) {
        for (uint8 miniRow = rowBlock; miniRow < rowBlock + 3; miniRow++) {
          for (uint8 miniCol = colBlock; miniCol < colBlock + 3; miniCol++) {
            uint8 cellValue = sudokuBoard[miniRow][miniCol];
            if (seenList.insert(count++, cellValue) == 1) return 1; // invalid
          }
        }
        count = 0; // for dev. can be removed
        blockNumber++;
        // seenList.reset();
        assertTest();
      }
    }
    // seenList.reset();
    assertTest();

    return 2;
  }

  function isValidRows(uint8[9][9] memory sudokuBoard) public returns(uint) {
   for (uint8 row = 0; row < 9; row++) {
      for (uint8 i = 0; i < 9; i++) {
        uint8 cellValue = sudokuBoard[row][i];
        if (seenList.insert(i, cellValue) == 1) return 1; // invalid
      }
    //   seenList.reset();
      assertTest();
    }
    assertTest();

    return 2;
  }

  function isValidColumns(uint8[9][9] memory sudokuBoard) public returns (uint) {
    // _flag = 0;

    for (uint8 col = 0; col < 9; col++) {
      for (uint8 i = 0; i < 9; i++) {
        uint8 cellValue = sudokuBoard[i][col];
        if (seenList.insert(i, cellValue) == 1) return 1; // invalid
      }
      assertTest();
    }

      assertTest();
      // console.log("true!!");
    //   _flag = 1;
      return 2;
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
