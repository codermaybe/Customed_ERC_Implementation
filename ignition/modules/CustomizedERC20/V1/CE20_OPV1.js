const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("CE20_OPV1", (m) => {
  const CE20V1 = m.contract("CE20_OPV1", ["100000"]);

  return { CE20V1 };
});
