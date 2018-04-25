function y = testAddOne(x)
%#codegen
  p = AddOne();
  y = p.step(x);
end  

