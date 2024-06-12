# Solidity and Yul
not for use in production.

## test inputs used - _0(zero) represents empty cell_
[valid array](https://github.com/thecodeslide/web3-Eth/main/Sudoku/#valid-array)\
[invalid block](https://github.com/thecodeslide/web3-Eth/main/Sudoku/README.md#invalidblock)\
[invalid column](https://github.com/thecodeslide/web3-Eth/main/Sudoku/README.md#invalidcolumn)\
[invalid row](https://github.com/thecodeslide/web3-Eth/main/Sudoku/README.md#invalidrow)\
[invalid row and column and block](https://github.com/thecodeslide/web3-Eth/main/Sudoku/README.md#invalidrow-and-col-and-block)\
[invalid row and column](https://github.com/thecodeslide/web3-Eth/main/Sudoku/README.md#invalidrow-and-col)\
[invalid row and block](https://github.com/thecodeslide/web3-Eth/Sudoku?tab=readme-ov-file#invalidrow-and-block)


> #### **valid array** 
  -  `[[5, 3, 0, 0, 7, 0, 0, 0, 0] ,[6, 0, 0, 1, 9, 5, 0, 0, 0] , [0, 9, 8, 0, 0, 0, 0, 6, 0] , [8, 0, 0, 0, 6, 0, 0, 0, 3] , [4, 0, 0, 8, 0, 3, 0, 0, 1] , [7, 0, 0, 0, 2, 0, 0, 0, 6] , [0, 6, 0, 0, 0, 0, 2, 8, 0] , [0, 0, 0, 4, 1, 9, 0, 0, 5] , [0, 0, 0, 0, 8, 0, 0, 7, 9]]`

> #### **invalid(block)**
  - `[[5, 3, 0, 0, 7, 0, 0, 0, 0] ,[6, 1, 0, 1, 9, 5, 0, 0, 0] , [3, 9, 8, 0, 0, 0, 0, 6, 0] , [8, 0, 0, 0, 6, 0, 0, 0, 3] , [4, 0, 0, 8, 0, 3, 0, 0, 1] , [7, 0, 0, 0, 2, 0, 0, 0, 6] , [0, 6, 0, 0, 0, 0, 2, 8, 0] , [0, 0, 0, 4, 1, 9, 0, 0, 5] , [0, 0, 0, 0, 8, 0, 0, 7, 9]]`

> #### **invalid(column)**
  - `[[5, 3, 0, 0, 7, 0, 0, 0, 0] ,[6, 0, 0, 1, 9, 5, 0, 0, 0] , [7, 9, 8, 0, 0, 0, 0, 6, 0] , [8, 0, 0, 0, 6, 0, 0, 0, 3] , [4, 0, 0, 8, 0, 3, 0, 0, 1] , [7, 0, 0, 0, 2, 0, 0, 0, 6] , [0, 6, 0, 0, 0, 0, 2, 8, 0] , [0, 0, 0, 4, 1, 9, 0, 0, 5] , [0, 0, 0, 0, 8, 0, 0, 7, 9]]`

> #### **invalid(row)**
  - `[[5, 3, 3, 0, 7, 0, 0, 0, 0] ,[6, 0, 0, 1, 9, 5, 0, 0, 0] , [0, 9, 8, 0, 0, 0, 0, 6, 0] , [8, 0, 0, 0, 6, 0, 0, 0, 3] , [4, 0, 0, 8, 0, 3, 0, 0, 1] , [7, 0, 0, 0, 2, 0, 0, 0, 6] , [0, 6, 0, 0, 0, 0, 2, 8, 0] , [0, 0, 0, 4, 1, 9, 0, 0, 5] , [0, 0, 0, 0, 8, 0, 0, 7, 9]]`

> #### **invalid(row and col and block)**
  - `[[5, 3, 0, 0, 7, 0, 0, 0, 0] ,[6, 9, 0, 1, 9, 5, 0, 0, 0] , [0, 9, 8, 0, 0, 0, 0, 6, 0] , [8, 0, 0, 0, 6, 0, 0, 0, 3] , [4, 0, 0, 8, 0, 3, 0, 0, 1] , [7, 0, 0, 0, 2, 0, 0, 0, 6] , [0, 6, 0, 0, 0, 0, 2, 8, 0] , [0, 0, 0, 4, 1, 9, 0, 0, 5] , [0, 0, 0, 0, 8, 0, 0, 7, 9]]`

> #### **invalid(row and col)**
  - `[[7, 3, 0, 0, 7, 0, 0, 0, 0] ,[6, 0, 0, 1, 9, 5, 0, 0, 0] , [0, 9, 8, 0, 0, 0, 0, 6, 0] , [8, 0, 0, 0, 6, 0, 0, 0, 3] , [4, 0, 0, 8, 0, 3, 0, 0, 1] , [7, 0, 0, 0, 2, 0, 0, 0, 6] , [0, 6, 0, 0, 0, 0, 2, 8, 0] , [0, 0, 0, 4, 1, 9, 0, 0, 5] , [0, 0, 0, 0, 8, 0, 0, 7, 9]]`

> #### **invalid(row and block)**
  - `[[5, 3, 0, 0, 7, 0, 0, 0, 0] ,[6, 0, 9, 1, 9, 5, 0, 0, 0] , [0, 9, 8, 0, 0, 0, 0, 6, 0] , [8, 0, 0, 0, 6, 0, 0, 0, 3] , [4, 0, 0, 8, 0, 3, 0, 0, 1] , [7, 0, 0, 0, 2, 0, 0, 0, 6] , [0, 6, 0, 0, 0, 0, 2, 8, 0] , [0, 0, 0, 4, 1, 9, 0, 0, 5] , [0, 0, 0, 0, 8, 0, 0, 7, 9]]`
 
> #### **invalid(row and block)**
  - `[[5, 3, 3, 0, 7, 0, 0, 0, 0] ,[6, 0, 0, 1, 9, 5, 0, 0, 0] , [0, 9, 8, 0, 0, 0, 0, 6, 0] , [8, 0, 0, 0, 6, 0, 0, 0, 3] , [4, 0, 0, 8, 0, 3, 0, 0, 1] , [7, 0, 0, 0, 2, 0, 0, 0, 6] , [0, 6, 0, 0, 0, 0, 2, 8, 0] , [0, 0, 0, 4, 1, 9, 0, 0, 5] , [0, 0, 0, 0, 8, 0, 0, 7, 9]]`

