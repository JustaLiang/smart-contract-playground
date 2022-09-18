import { expect } from "chai";
import { setupERC721AntiRugPull } from "../fixture/setup-contracts";

describe("ERC721AntiRugPull", function () {
  let tx, receipt, gasFee;

  it("Negative: Cant't set redeemable under report threshold", async function () {
    const { contract, users, mintPrice, reportThresold } = await setupERC721AntiRugPull();
    const user = users[0];
    const amount = reportThresold.div(2).toNumber();
    tx = await contract.connect(user).mint(amount, { value: mintPrice.mul(amount) });
    await tx.wait();
    const tokenIdList = await Promise.all(
      [...Array(amount).keys()].map(async (index) => {
        return await contract.tokenOfOwnerByIndex(user.address, index);
    }));
    tx = await contract.connect(user).report(tokenIdList);
    await tx.wait();
    expect(await contract.balanceOf(user.address)).equal(0);
    expect(await contract.totalReportAmount()).equal(amount);
    await expect(contract.connect(user).setRedeemable())
    .revertedWith("Report amount not enough");
  });

  it("Positive: set redeemable", async function () {
    const { contract, users, mintPrice, reportThresold } = await setupERC721AntiRugPull();
    const reporter = users[1];
    const redeemer = users[2];
    const amount = 5;
    tx = await contract.connect(reporter).mint(reportThresold, { value: mintPrice.mul(reportThresold) });
    await tx.wait();
    tx = await contract.connect(redeemer).mint(amount, { value: mintPrice.mul(amount) });
    await tx.wait();

    const reporterTokenIdList = await Promise.all(
      [...Array(reportThresold.toNumber()).keys()].map(async (index) => {
        return await contract.tokenOfOwnerByIndex(reporter.address, index);
    }));

    tx = await contract.connect(reporter).report(reporterTokenIdList);
    await tx.wait();
    expect(await contract.totalReportAmount()).equal(reportThresold);
    tx = await contract.connect(reporter).setRedeemable();
    await tx.wait();
    expect(await contract.redeemable()).equal(true);

    const reporterRefund = await contract.returningValue(reporter.address);
    expect(reporterRefund).equal(mintPrice.mul(reportThresold));
    const initReporterBalance = await reporter.getBalance();
    tx = await contract.connect(reporter)["redeem()"]();
    receipt = await tx.wait();
    gasFee = receipt.gasUsed.mul(receipt.effectiveGasPrice);
    expect(await reporter.getBalance()).equal(initReporterBalance.sub(gasFee).add(reporterRefund));
  
    const redeemerTokenIdList = await Promise.all(
      [...Array(amount).keys()].map(async (index) => {
        return await contract.tokenOfOwnerByIndex(redeemer.address, index);
    }));

    const initRedeemerBalance = await redeemer.getBalance();
    tx = await contract.connect(redeemer)["redeem(uint256[])"](redeemerTokenIdList);
    receipt = await tx.wait();
    gasFee = receipt.gasUsed.mul(receipt.effectiveGasPrice);
    const redeemerRefund = mintPrice.mul(amount);
    expect(await redeemer.getBalance()).equal(initRedeemerBalance.sub(gasFee).add(redeemerRefund));
  });
});
