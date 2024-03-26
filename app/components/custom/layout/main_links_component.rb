class Layout::MainLinksComponent < ApplicationComponent
  use_helpers :image_path_for

    private

      def sections
        {
          cabildo:
            { path: "/_cabildo_que-es-el-cabildo-abierto", img: "cabildo-abierto.png" },
          transparency:
            { path: "https://transparencia.tenerife.es/", img: "transparencia.png", target: "_blank" },
          collaboration:
            { path: "/_participacion_que-hacemos", img: "participacion-colaboracion.png" },
          open_data:
            { path: "https://datos.tenerife.es/es/", img: "datos-abiertos.png", target: "_blank" },
          ethics:
            { path: "/_etica_codigo-de-buen-gobierno-y-seguimiento", icon: "balance-scale" }
        }
      end
end
