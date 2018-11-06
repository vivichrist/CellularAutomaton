let project = new Project('CellAShader');

project.addAssets('Assets/**');

project.addSources('Sources');

project.addShaders('Sources/Shaders/**');

project.addLibrary('zui');

resolve(project);
