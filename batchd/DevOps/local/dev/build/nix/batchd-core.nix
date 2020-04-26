{ mkDerivation, aeson, base, bytestring, containers, dates
, directory, filepath, heavy-logger, hsyslog, localize, mtl
, persistent, persistent-template, resourcet, scotty, stdenv, syb
, template-haskell, text, text-format-heavy, th-lift, time
, unordered-containers, wai, yaml
}:
mkDerivation {
  pname = "batchd-core";
  version = "0.1.0.0";
<<<<<<< HEAD
  src = /home/chenjf/projects/my-devops-framework/batchd/DevOps/local/dev/build/../../../../batchd-core;
=======
<<<<<<< HEAD
  src = /home/chenjf/projects/my-devops-framework/batchd/DevOps/local/dev/build/../../../../batchd-core;
=======
  src = /Users/chenjinfen/Desktop/projects/my-devops-framework/batchd/DevOps/local/dev/build/../../../../batchd-core;
>>>>>>> cf4be9cce62086418b9c0f3d0ae5baff0568507f
>>>>>>> e4d78b3d132d2780312f982456e85d7e9c978635
  libraryHaskellDepends = [
    aeson base bytestring containers dates directory filepath
    heavy-logger hsyslog localize mtl persistent persistent-template
    resourcet scotty syb template-haskell text text-format-heavy
    th-lift time unordered-containers wai yaml
  ];
  homepage = "https://github.com/portnov/batchd";
  description = "Core modules of batchd, to use in batchd extensions";
  license = stdenv.lib.licenses.bsd3;
}
