const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("CE20V1", (m) => {
  const CE20V1 = m.contract("CE20V1", ["CE20V1", "CE20V1", 18, 10000]);

  return { CE20V1 };
});
