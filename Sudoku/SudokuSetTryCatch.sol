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

//   error duplicateError(uint8, string, bytes4);
  // event insertLog(address indexed sender, uint indexed key, uint value);

  function insert(Set storage set, uint8 key, uint8 cellValue) internal {
    require(cellValue < 0xA, "value too high"); // move to contract???
    
    // if(cellValue > 0 ) set.values[cellValue] = 1;
    // set.has[cellValue -1] = 1; 
    // else  {
    //   set.values[cellValue - 1] = 1; // TODO
    //   set.has[cellValue] = 1;
    // }
    assert(contains(set, cellValue) == 0);    // revert duplicateError(cellValue, action, hex'DEADBEEF');
    if(cellValue != 0 ) {
      set.has[cellValue] = 1;
      assert(contains(set, cellValue) == 1);
      // emit insertLog(msg.sender, key, cellValue);
    }
    
    set.values[key] = cellValue;
  }

  function contains(Set storage set, uint8 cellValue) internal view returns(uint flag) {
    if(set.values.length == 0) return 0; // 
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
//   event Log(string message);
  event Log(address sender, string action, uint8 key);
  event LogError(string message);
  event LogPanic(uint panic, string message);
  event LogBytes(bytes data);

  function isValid(uint8[INDEX][INDEX] memory sudokuBoard) public returns (uint, bool) {
    // TODO
    // if (!isValidRowsAndColumns(sudokuBoard)) {
    //     return false;
    // }
    try this.isValidRows(sudokuBoard) { //returns (uint) {
      emit Log(msg.sender, "validRows", 2);
    //   return (2, true);
    }
    catch Error(string memory errorText) {  
      emit LogError(errorText);
      return (1, false);
    }
    catch Panic(uint errCode) {
      emit LogPanic(errCode, "row");
      return (1, false);
    }
    catch (bytes memory lowLevelData) {
      emit LogBytes(lowLevelData);
      return (1, false);
    }

    try this.isValidColumns(sudokuBoard) {
      emit Log(msg.sender, "ValidColumns", 2);
    }
    catch Error(string memory errorText) {  
      emit LogError(errorText);
      return (3, false);
    }
    catch Panic(uint errCode) {
      emit LogPanic(errCode, "cols");
      return (3, false);
    }
    catch (bytes memory lowLevelData) {
      emit LogBytes(lowLevelData);
      return (3, false);
    }

    try this.isValidBlocks(sudokuBoard) {
      emit Log(msg.sender, "ValidBlocks", 2);
      return (2, true);
    }
    // catch Error(string memory errorText) {  
    //   emit LogError(errorText);
    //   return (4, false);
    // }
    catch Panic(uint errCode) {
      emit LogPanic(errCode, "block");
      return (4, false);
    }
    // catch (bytes memory lowLevelData) {
    //   emit LogBytes(lowLevelData);
    //   return (4, false);
    // }
  
  }

  function isValidBlocks(uint8[INDEX][INDEX] memory sudokuBoard) public  {
    uint8 blockNumber = 0;
    uint8 count = 0; // for dev. can be removed

    for (uint8 rowBlock = 0; rowBlock < 9; rowBlock += 3) {
      for (uint8 colBlock = 0; colBlock < 9; colBlock += 3) {
        for (uint8 miniRow = rowBlock; miniRow < rowBlock + 3; miniRow++) {
          for (uint8 miniCol = colBlock; miniCol < colBlock + 3; miniCol++) {
            uint8 cellValue = sudokuBoard[miniRow][miniCol];
            seenList.insert(count++, cellValue);
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
    // emit Log("blocks");
  }

  function isValidRows(uint8[9][9] memory sudokuBoard) public {
    // _flag = flag;

   for (uint8 row = 0; row < 9; row++) {
      for (uint8 i = 0; i < 9; i++) {
        uint8 cellValue = sudokuBoard[row][i];
        seenList.insert(i, cellValue);

      }
    //   seenList.reset();
      assertTest();
    }
    assertTest();
    // emit Log("row");
  }

  function isValidColumns(uint8[9][9] memory sudokuBoard) public  {
    // _flag = 0;

    for (uint8 col = 0; col < 9; col++) {
      for (uint8 i = 0; i < 9; i++) {
        uint8 cellValue = sudokuBoard[i][col];
        seenList.insert(i, cellValue);

      }
      assertTest();
    }

      assertTest();
      // emit Log("Cols");
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
