// NON-AI AGPL-3.0-only

pragma solidity ^0.8.17;

import "hardhat/console.sol";
//  import "woke/console.sol";
// import "./LibrarySet.sol";

library SetSudokuLib {
  struct Set  {
    uint8[9]  values; //TODO
    mapping (uint8 => uint8) has;
  }

  error duplicateError(uint8, string, bytes4);
  // event insertLog(address indexed from, uint indexed key, uint value);

  function insert(Set storage set, uint8 key, string memory action, uint8 cellValue) internal {
    require(cellValue < 0xA, "value too high");
    
    if (contains(set, cellValue) == 1) revert duplicateError(cellValue, action, hex'DEADBEEF');
    if(cellValue != 0 ) {
      set.has[cellValue] = 1;
      assert(contains(set, cellValue) == 1);
      //   emit insertLog(msg.sender, key, cellValue);
    }
    
    set.values[key] = cellValue;
  }

  function contains(Set storage set, uint8 cellValue) internal view returns(uint flag) {
    if(set.values.length == 0) return 0;
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

//   uint8 flag = 1; // false
  SetSudokuLib.Set seenList;
  // event Log(address sender, string action, uint8 key);
  // event LogError(string message);
  // event LogPanic(uint panic);
  // event LogBytes(bytes data);

  function isValid(uint8[INDEX][INDEX] memory sudokuBoard) public returns (uint) {
    // TODO
    // if (!isValidRowsAndColumns(sudokuBoard)) {
    //     return false;
    // }
    // try this.isValidRows(sudokuBoard) returns (uint) {
    //   emit Log(msg.sender, "validRows", 2);
    //   // return (2, true);
    // }
    // catch Error(string memory errorText) {  
    //   emit LogErrorString(errorText);
    //   return (1, false);
    // }
    // catch Panic(uint errCode) {
    //   emit LogPanicCode(errCode);
    //   return (1, false);
    // }
    // catch (bytes memory lowLevelData) {
    //   emit LogBytes(lowLevelData);
    //   return (1, false);
    // }
  

    isValidRows(sudokuBoard);
    isValidColumns(sudokuBoard);
    isValidBlocks(sudokuBoard);
    return 2; // true
  }

  function isValidBlocks(uint8[INDEX][INDEX] memory sudokuBoard) public {
    uint8 blockNumber = 0;
    uint8 count = 0; // for dev. can be removed

    for (uint8 rowBlock = 0; rowBlock < 9; rowBlock += 3) {
      for (uint8 colBlock = 0; colBlock < 9; colBlock += 3) {
        for (uint8 miniRow = rowBlock; miniRow < rowBlock + 3; miniRow++) {
          for (uint8 miniCol = colBlock; miniCol < colBlock + 3; miniCol++) {
            uint8 cellValue = sudokuBoard[miniRow][miniCol];
            seenList.insert(count++, "blocks", cellValue);
            // continue if no value assigned to cell
 
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

    console.log("true");
    // return 2;
  }

  function isValidRows(uint8[9][9] memory sudokuBoard) public {
    // _flag = flag;

   for (uint8 row = 0; row < 9; row++) {
      for (uint8 i = 0; i < 9; i++) {
        uint8 cellValue = sudokuBoard[row][i];
        seenList.insert(i, "rows", cellValue);
      }
      assertTest();
    }
    assertTest();
    console.log("true!!");
  }

  function isValidColumns(uint8[9][9] memory sudokuBoard) public {
    // _flag = 0;

    for (uint8 col = 0; col < 9; col++) {
      for (uint8 i = 0; i < 9; i++) {
        uint8 cellValue = sudokuBoard[i][col];
        seenList.insert(i, "col", cellValue);

      }
      
      assertTest();
    }
    // delete _columnSet;

      assertTest();
      console.log("true!!");

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



