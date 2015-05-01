classdef tfw_ConvReluPoolDrop < tfw_i
  %TFW_CONVRELUPOOLDROP Conv + Relu + Pooling + Dropout
  %   Detailed explanation goes here
  
  properties
  end
  
  methods
    function ob = tfw_ConvReluPoolDrop()
  
      %%% internal connection
      % 1: conv, param
      ob.tfs{1}        = tf_conv();
      ob.tfs{1}.p(1).a = randn(0, 0, 'single'); % kernel
      ob.tfs{1}.p(2).a = zeros(0, 0, 'single'); % bias
      % 2: relu
      ob.tfs{2}   = tf_relu();
      ob.tfs{2}.i = ob.tfs{1}.o;
      % 3: pool
      ob.tfs{3}   = tf_pool();
      ob.tfs{3}.i = ob.tfs{2}.o;
      % 3: dropout
      ob.tfs{4}   = tf_dropout();
      ob.tfs{4}.i = ob.tfs{3}.o;
      
      %%% input/output data
      ob.i = n_data();
      ob.o = n_data();

      %%% set the parameters
      ob.p = dag_util.collect_params( ob.tfs );
      
    end % tfw_LinReluDrop
    
    function ob = fprop(ob)
      % outer -> inner
      ob.tfs{1}.i.a = ob.i.a; 
      % fprop all
      for i = 1 : numel( ob.tfs )
        ob.tfs{i} = fprop(ob.tfs{i});
        ob.ab.sync();
      end
      % inner -> outer
      ob.o.a = ob.tfs{end}.o.a; 
    end % fprop
    
    function ob = bprop(ob)
      % outer -> inner
      ob.tfs{end}.o.d = ob.o.d; 
      % bprop all
      for i = numel(ob.tfs) : -1 : 1
        ob.tfs{i} = bprop(ob.tfs{i});
        ob.ab.sync();
      end
      ob.i.d = ob.tfs{1}.i.d; 
    end % bprop
  end
  
end

