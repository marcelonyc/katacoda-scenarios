#!/usr/bin/env python
# coding: utf-8

# In[ ]:


# nuclio: ignore
# do not remove the comment above (it is a directive to nuclio, ignore that cell during build)
# if the nuclio-jupyter package is not installed run !pip install nuclio-jupyter and restart the kernel 
import nuclio 


# We use `%nuclio` magic commands to set package dependencies and configuration:

# In[ ]:


get_ipython().run_line_magic('nuclio', 'cmd -c pip install pandas')
get_ipython().run_line_magic('nuclio', 'config spec.build.baseImage = "mlrun/mlrun"')


# The ```DataItem```s and the ```context``` within which they are logged are described in the following ```mlrun``` modules (they are included here only for type clarity).

# In[ ]:


from mlrun.execution import MLClientCtx
from mlrun.datastore import DataItem


# In[ ]:


import time

def training(
    context: MLClientCtx,
    p1: int = 1,
    p2: int = 2
) -> None:
    """Train a model.

    :param context: The runtime context object.
    :param p1: A model parameter.
    :param p2: Another model parameter.
    """
    # access input metadata, values, and inputs
    print(f'Run: {context.name} (uid={context.uid})')
    print(f'Params: p1={p1}, p2={p2}')
    context.logger.info('started training')
    
    # <insert training code here>
    
    # log the run results (scalar values)
    context.log_result('accuracy', p1 * 2)
    context.log_result('loss', p1 * 3)
    
    # add a lable/tag to this run 
    context.set_label('category', 'tests')
    
    # log a simple artifact + label the artifact 
    # If you want to upload a local file to the artifact repo add src_path=<local-path>
    context.log_artifact('model', 
                          body=b'abc is 123', 
                          local_path='model.txt', 
                          labels={'framework': 'tfkeras'})


# In[ ]:


def validation(
    context: MLClientCtx,
    model: DataItem
) -> None:
    """Model validation.
    
    Dummy validation function.
    
    :param context: The runtime context object.
    :param model: The extimated model object.
    """
    # access input metadata, values, files, and secrets (passwords)
    print(f'Run: {context.name} (uid={context.uid})')
    print(f'file - {model.url}:\n{model.get()}\n')
    context.logger.info('started validation')    
    context.log_artifact('validation', 
                         body=b'<b> validated </b>', 
                         format='html')


# The following end-code annotation tells ```nuclio``` to stop parsing the notebook from this cell. _**Please do not remove this cell**_:

# In[ ]:


# nuclio: end-code


# ______________________________________________

# In[ ]:


from mlrun import run_local, code_to_function, mlconf, NewTask
from mlrun.platforms import mount_pvc
mlconf.dbpath = mlconf.dbpath or 'http://mlrun-api:8080'


# <b> define the artifact location</b>

# In[ ]:


from os import path
out = mlconf.artifact_path or path.abspath('./data')
# {{run.uid}} will be substituted with the run id, so output will be written to different directoried per run
artifact_path = path.join(out, '{{run.uid}}')


# #### _running and linking multiple tasks_
# In this example we run two functions, ```training``` and ```validation``` and we pass the result from one to the other.
# We will see in the ```job``` example that linking works even when the tasks are run in a workflow on different processes or containers.

# ```run_local()``` will run our task on a local function:

# Run the training function. Functions can have multiple handlers/methods, here we call the ```training``` handler:

# In[ ]:


train_run = run_local(NewTask(handler=training, params={'p1': 5}, artifact_path=out))


# After the function runs it generates the result widget, you can click the `model` artifact to see its content.

# In[ ]:


train_run.outputs


# The output from the first training function is passed to the validation function, let's run it:

# In[ ]:


model_path = train_run.outputs['model']

validation_run = run_local(NewTask(handler=validation, inputs={'model': model_path}, artifact_path=out))

