/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_testAddOne_info.c
 *
 * Code generation for function '_coder_testAddOne_info'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "testAddOne.h"
#include "_coder_testAddOne_info.h"

/* Function Definitions */
mxArray *emlrtMexFcnProperties(void)
{
  mxArray *xResult;
  mxArray *xEntryPoints;
  const char * fldNames[6] = { "Name", "NumberOfInputs", "NumberOfOutputs",
    "ConstantInputs", "FullPath", "TimeStamp" };

  mxArray *xInputs;
  const char * b_fldNames[4] = { "Version", "ResolvedFunctions", "EntryPoints",
    "CoverageInfo" };

  xEntryPoints = emlrtCreateStructMatrix(1, 1, 6, fldNames);
  xInputs = emlrtCreateLogicalMatrix(1, 1);
  emlrtSetField(xEntryPoints, 0, "Name", emlrtMxCreateString("testAddOne"));
  emlrtSetField(xEntryPoints, 0, "NumberOfInputs", emlrtMxCreateDoubleScalar(1.0));
  emlrtSetField(xEntryPoints, 0, "NumberOfOutputs", emlrtMxCreateDoubleScalar
                (1.0));
  emlrtSetField(xEntryPoints, 0, "ConstantInputs", xInputs);
  emlrtSetField(xEntryPoints, 0, "FullPath", emlrtMxCreateString(
    "C:\\Users\\Krishna Bhatia\\MATLAB\\Projects\\ManavMantra\\genCode\\testAddOne.m"));
  emlrtSetField(xEntryPoints, 0, "TimeStamp", emlrtMxCreateDoubleScalar
                (737175.5191898148));
  xResult = emlrtCreateStructMatrix(1, 1, 4, b_fldNames);
  emlrtSetField(xResult, 0, "Version", emlrtMxCreateString(
    "9.4.0.813654 (R2018a)"));
  emlrtSetField(xResult, 0, "ResolvedFunctions", (mxArray *)
                emlrtMexFcnResolvedFunctionsInfo());
  emlrtSetField(xResult, 0, "EntryPoints", xEntryPoints);
  return xResult;
}

const mxArray *emlrtMexFcnResolvedFunctionsInfo(void)
{
  const mxArray *nameCaptureInfo;
  const char * data[25] = {
    "789ced5dcd8f1b4915ef2c4936d16a21d20a7601c126bb10c1068dbfc699994888f1f7783c1edb63cf8cc7d9dd497fd96ebb3feceeb6c7f6694e682f48fc0188"
    "f382b408b86c2438180901470ec081d35e9038ae84e0c401b7dbe5b11b57dc1397cbd33d5552d2a97aeef7aa5e5efd5e55bdea2aea46327d83a2a82f0efe184f",
    "ef67d430bd6e3ea87ba3e72bd474b2d26f8c9edfb6e441ba45dd9c7a0fd07f327ab28aacf31dddcc8882ccefb724865707199996f8311b4e91049996f542b7c1"
    "532aaf29629be78694b220f20541e2f79489cc8e30c848f109d23863908c7f47aa3c5bcfb7244aad6a17d5152733d4847efe0469ff4d9bfa6121fab9372a03f4",
    "a7c962e483c8134f56552a2a2ddd37aaaa79d2a1c25e28ec39f07b7d9bb447571491513a1ead4aab3ce7d1ba9ace4b1e56e178d5f348a27591663c8f46a58fcc"
    "e2fc303760da586b4cb5eb19a4deb76db6cbfa04e92e756722f7f90f80bc8f20fceceaf11d883ca047401f367b4d1818972ad3e29aa995c8a0b0c2cb3bb4cc89",
    "23db9aa707bbf57a155aaf5787652db92e2b67f2585e7f4179a750796619a03f4deed93728d3564686347a00157a66a870604bf8eca8cff47efab7105ebbc5dd"
    "4f5627af03e167d71ebf029107ec11d083c75ccbafa57aeb7e21198fb74445f285999d8b7a64e7c899570f0a92c7c5bf0f791f7dbf5ea29fc0daaf8d74e11fce",
    "21fceceaef9b1079407f806e367fcd6cfd9ae92d2e9ce4eafc021967cc6e970d3bfa6387f807c7fb8772a45bd25367c7075aaf5e614ac16366af538db9c73fb8"
    "a27f47149527f308328f20f3882b8fdbb8e59179041afe7dc8fb641e319daeee3cc27092641ee1c0710699472c511e2eff50dc3ce8d5785edaab24d874bd5662",
    "4fc4b82fec1efff031e47dbb7a4c40f8033d02fad361ef3ed47855f3a45441abcaf4fd7095d6051a74f241cfaff1ac3ee8f4b44cb7077fe92aed190ced8c119e"
    "27c47119995f931ceb07be069107f404e8703f60d2dd3f3f70cb38a2ff0782ff2ec0ff83287da61f1e86baea867e747212f472273917cd0f7e0979dfae1e5310",
    "fe408f80fe34b610feebbca68f7dc064fd9f41ea87d6eeee6ca3c2dddb963c35fedded6199d9c8c571de9a60ff3f2091f1c0ec7a5fd8c1f927ef3d2778ee743c"
    "f7865a8a4ec7831b3b256157883d4e737b5b09178de75d315fbf02fb8bce21fc9c163fb626bb7e80d8d1ec76d9b023b2eeb34479247e8c86bf2bfaf715881f9f",
    "43f8392d3e604dd7ca4f90f880ebe491f8001afea47fcf6ed765fd4403c2cfae1e5f83c8037a0474b925f1aac0eac6f72d465a955f58745d313d471ea01bfb89"
    "62760d8797448f28309eb2d0e1b98622c8ba67425fc395458cf6f1c9f157ff4af07f49f216c5ff2f43e401fb03f45e45de49744a5beac1e3e861b15e627b6c5b",
    "a708fe13fc37d205fee3b247cb3e5391972b7a9572ae1fd89f230fd02fed078c3fffb7a7d45497e108f0d9c9f687bf7f83cc039cee070a7b47a52d892baaa1e3"
    "f58d8e2f702479f75314f103c40f18e9c20fc0e4d9d5e31720f2ee0d28469924c8c33cae7835a7b418914787f749a83cb30cd05f6adc3fb20d8ed6e9724bf60c",
    "7435da4d8015ef3fbfcb9271ff55c57bbbeb3e5ba96eb2a82bd12d5fedccdf0da6378f52f94ad43d784ffaf1ecfa4fdbddfd6d5476f716441ed017a05bc6f732"
    "ad560499add65735beefbfa43cc0ebfd39f200fd5276321a18bcf0f3b1b1e64cd3c1b88fe88d27077f21f8bf2479b8f0bfdb394b6ed1f17225e8653331255f8b",
    "b736ce5c141fee43de776abf86d9855d3b848dbbef8e9e6f4d95beb36d3e1f8e9edf43b67ff416a41ef70614a3ac2c2a8a71ea1519ffc3c70dbc688c1a869a5a"
    "c5b8e177870fc9f8dfe9f8bfd9dcc8149a6234580f570bb9445e6f46a36cdc3df84ffaf1ecfac3c6ffe7107e76f5f536441ed017a05bc6ff82166e09a29e94f7",
    "cd38e6ca70fff982f28a50796619a0a359e7b7aa6d4dc238fefff4df7f27f8ef74fccfb49b915079a7bd59c8ad77d99824fbe325917c1776cdf0ff5bc8f0ffeb"
    "1079405f806ec17f8da5455a5d03a3fed5c57917c5ffc339f2001d0dfe3f32f536613b18f1ffe764df8ff3f19fa93ece166551e7f28a146bc93b012616de4d10",
    "fcbfaef8ff63083fbbfafa2e441ed017a05bf09f6e34c46e7e0866f196ccea822227e5ac48b3e0c87354fb4fbf34a77e805e1ed5e2b46a1e6a876aff0033473e"
    "a0a3f10f70b50243c367677de6b51ad91fe4747fa1d07b3586a613112eb059d38a7e3e5d6a745d142f26fd7b76bbecd923baf8c01d4b9e1affeeceb04cd0b406",
    "ad6abc53e3034bdb0f3a31ae3034648c2c80ae30ef07bdf3fd0f09de3b1defcf8e935a5cac1fc5fd65352fb66b995db9978b10bc27786fa435d7ad1bbdac3f20"
    "eb46b39f209175233cf2c8ba111afe4e58375afdbed1f790ed1b7d13220fe80bd0adf70f0872464dd31d64b87fd392bfa8c7cd61195ba5878e06959d642d796a",
    "e27793768e06f781bab0c689dffdef8fc83cc0e978af56247d4f6753cdaa90e9723d291ae076c9f9a1d7a91f1b091dde93ef0466cb23df092c2acf4cd7451ef9"
    "4e000dff45d781ca10fe408f808e1aff1fb4061dbb9b51c382f18c0a5a83d6d92a6e7b7c42fcc24bca237ee17ae0346e79c42fa0e14ffcc2ec76d9b2c7f310b2",
    "f8c03720f2801e01dde2179861f3d36095085d7ce0b2eb448bc6078ea0f2cc3240476347d36ac31b373ecffc4b27eb454ef70b4c29516282ed635ae3fd5237b6"
    "2eb78274cf457163d29f673f4182c589c9fce072f2c8fce07ae0326e79647e8086ffa2f3830a843fd023a02fc70f3c300b322dbdd1d20bc659cb78edf170d5f1",
    "63731f4cace2d87326b2963c35f1bb49fb47633f405d58e3c7bf7848f6913ade0f780f2abeb6bebba5a895aa968fd395703cd976d17703a41fcfaefff47a507a"
    "8cf70d083fbbfa7add92a7267e7763822e68d337093815e73350796619a02f7a8fc094bef0de534dee1158a23c5c389f08d4bbf9664510238548fda019ae14ea",
    "873182f3d716e761f2d07d075616245aaf3a15d777a1f2cc32405f1cd74d3dade03b1182eb4b9487eb5e8076938f35daacb6553c0b284a56cbfb022725ca3db8"
    "eeac73bf2e70fd41595035bd2c60b5bffe3364715dbbf7460ed4703a68fe6959514545699c2a6d5e2d8bcad9295be5d9faeace0beabfa43cc0eb99256f9507e8",
    "0b9d2f629ad10bf487737cd0ffed3f6e91f59cabea0fec8ef3b554ac138bf67ad9dd8e7f3dedf74672219fd745ebfaff84bc6f578f3f84f0077a04f465f7eb07"
    "2ffec16995171bbc8adb5e13c8e607f3f6e118e35e23bfe2388320737c2729ebe37a7cbc603de273ea01e828e60d98f70b3c27e78a3adf3fe4bb0d410a360f8e",
    "7d02c3ad274bb96cdae7a6f57ed27fa7d3b4bd795db3ce8ffb7b60b2ce8f5cde305d1779649d1f0d7f32fe9f6e175a7b4d221bffcf5baf1f345d3236fe3bd51f"
    "2c353e303e7f76f00f8fa9a9159c0bfafccdbb643dc8e9fe406d7a1b35415b0f498fb31b7296290652475a98f803e20f66b77b3a5e8cd71f18570b137f60c71f",
    "5c1c2c85d11ffc86f803e7fb830a7db291091cef373798901e09d299757e3de7a2f3e148bc78f613a429fbfbec19327cbfec7affa2f22ebb1f88ac0b4e27b2ae"
    "8f471e59d747c3dfb1b8dee355456b8df771c0d6ddeddadf2b9076807b82ef4d166e7fb03d7cf6dfc786f3e596281a79b2ef73fef9ff86aef08fe3cf7f45d6f9",
    "9d8ff7fa63bf74103d4e544b01a5d7d6d3523cedd309de8ff95daf731cf630eeeb27f7bb90fb5dae0edee29647ee7741c39fe0fbec2748d3f6b73fc6f78f20fc"
    "eceaed3b1079406f803eeb1e48f3ccbae96b6e50ed275af5fd8ff41cf9808ef0bea059ea5cc17d11e7bffe994afc85d3fd452e17d1ebd99a778329eda7f69902",
    "bd99496b71f7f80bd2bf67b7cb9e3d6e20f31fef42e4013d02bad57fb415810ba92add8d8bb4aef3b2209b272839f5fbb0a59cfb06b7a719eac37dee1b75fe1f"
    "86f809a7fb89deee4e2072d8284a3926c3858ae59d7447cab8e8be983f43deb7abc73a843fd023a02fe9dc37337010b69e8e8c7bdfcf09b2ef88df86c803fa04",
    "74eb77595ab825887a52de3777c3af2c9ee0acb893556d58cf83fb94c4919def1f32ed662454de696f1672eb5d3626c9fe784974817ff81ffe27e1de",
    "" };

  nameCaptureInfo = NULL;
  emlrtNameCaptureMxArrayR2016a(data, 57416U, &nameCaptureInfo);
  return nameCaptureInfo;
}

/* End of code generation (_coder_testAddOne_info.c) */
