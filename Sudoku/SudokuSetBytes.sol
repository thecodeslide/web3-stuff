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

  error duplicateError(bytes1, bytes32 , bytes4);

  function insert(Set storage set, uint key, bytes32 action, bytes1 cellValue) internal {
    require(cellValue < hex'0A', "number too high");
    // require(contains(set, cellValue) == 0, "error. duplicate.");
    
    // if(cellValue > 0 ) set.values[cellValue] = 1;
    // set.has[cellValue -1] = 1;
    // else  {
    //   set.values[cellValue - 1] = 1;
    //   set.has[cellValue] = 1;
    // }
    if (contains(set, cellValue) == hex'01') revert duplicateError(cellValue, action, hex'DEADBEEF');
    if(cellValue != 0 ) {
      set.has[cellValue] = hex'01';
      assert(contains(set, cellValue) == hex'01');
      // emit insertLog(msg.sender, key, cellValue);
    }
    
    // set.values[key] = cellValue;s
  }

  function contains(Set storage set, bytes1 cellValue) internal view returns(bytes1) {
    if(set.values.length == 0) return 0; // 
    return set.has[cellValue];// {//return 1;
  }

   function reset(Set storage set) internal {
      delete set.values;
     
      for(uint j = 1; j < 10; j++) {
        //  set.has[bytes1(j)] >>= 1;
        set.has[bytes1(uint8(j))] = hex'00';
        
        assert(set.has[bytes1(uint8(j))] == hex'00');
      }
    }
}

contract Sudoku {
  // int8[9][9] public board;
  using SetSudokuLib for SetSudokuLib.Set;
  uint8 constant INDEX = 9;
    
//   uint8 flag = 0;
  SetSudokuLib.Set seenList;
  // Set seenList;
  event Log(string indexed message);
  // event Log(address sender, string action, uint8 key);
  // event LogErrorString(string message);
  // event LogPanicCode(uint panic);
  // event LogBytes(bytes data);

  function isValid(uint[INDEX][INDEX] calldata sudokuBoard) public returns (uint) {
    // TODO
    // if (!isValidRowsAndColumns(sudokuBoard)) {
    //     return false;
    // }
    // try this.isValidRows(sudokuBoard) returns (uint) {
    //   emit Log(msg.sender, "validRows", 2);
    //   // return (2, true);
    // }


    isValidRows(sudokuBoard);
    isValidColumns(sudokuBoard);
    isValidBlocks(sudokuBoard);
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
    // seenList.reset();
    assertTest();
    // emit Log("blocks");
    // console.log("true1");
  }

  function isValidRows(uint[9][9] calldata sudokuBoard) public {
    // _flag = flag;

   for (uint row = 0; row < 9; row++) {
      for (uint i = 0; i < 9; i++) {
        bytes1 cellValue = bytes1(uint8(sudokuBoard[row][i]));
        seenList.insert(i, "rows", cellValue);
  
      }
      assertTest();
    }
    // seenList.reset();
    assertTest();
    // emit Log("row");
  }

  function isValidColumns(uint[9][9] calldata sudokuBoard) public {
    // _flag = 0;

    for (uint col = 0; col < 9; col++) {
      for (uint i = 0; i < 9; i++) {
        bytes1 cellValue = bytes1(uint8(sudokuBoard[i][col]));
        seenList.insert(i, "col", cellValue);

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
