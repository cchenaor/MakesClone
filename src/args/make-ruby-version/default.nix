{ __nixpkgs__
, ...
}:
version:
{
  "2.6" = __nixpkgs__.ruby_2_6;
  "2.7" = __nixpkgs__.ruby_2_7;
  "3.0" = __nixpkgs__.ruby_3_0;
}.${version}
