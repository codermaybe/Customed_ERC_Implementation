# 使用方法
- git clone 此项目
- npm i 补全包依赖
## 声名
此项目所有代码均为个人审计检验，谨慎检查代码，谨慎修改后再用于生产，风险自担。
## 前置条件
设置hardhat.config.js中network选项，自行添加对应网络的url和私钥(未引入dotenv，建议手动填写或自行修改)

## 部署(ignition)
`npx hardhat ignition deploy ./ignition/modules/Your_script_path/your_script_name.js --network Your_NetWork`
## 测试
- 完全测试  `npx hardhat test`
- 指定文件测试 `npx hardhat test ./test/Your_script_path/your_script_name.js`          ||  `--network Your_NetWork`可选
- 名称匹配测试 `npx hardhat test --grep "Your_test_name" `   ||  `--network Your_NetWork`可选
- 给指定脚本添加`.only` 标记
