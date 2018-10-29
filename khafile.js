let project = new Project('CellAShader');

project.addSources('Sources');

project.addShaders('Sources/Shaders/**');

resolve(project);
