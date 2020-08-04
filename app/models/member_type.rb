 class MemberType < ActiveRecord::Base
      def self.can_vote?(user, memberTypeIds)

        if (memberTypeIds.nil?) || (memberTypeIds.empty?) || (memberTypeIds.include? 1) then return true; end

        if (user.nil?) || (user[:document_number].nil?) then return false; end

        if ((memberTypeIds.include? 2) && ConectorRegistroEntidadesJuridicas.validUserAsoc?(user, MemberType.find(2)[:url_ws])) then return true; end
        if ((memberTypeIds.include? 3) && ConectorRegistroEntidadesJuridicas.validUserFund?(user, MemberType.find(3)[:url_ws])) then return true; end

        return false
      end

      def self.can_vote_proposals?(user, memberTypeIds)
        return MemberType.can_vote?(user, memberTypeIds)
      end

      def self.can_vote_polls?(user, memberTypeIds)
        return MemberType.can_vote?(user, memberTypeIds)
      end

      def self.can_vote_budgets?(user, memberTypeIds)
        return MemberType.can_vote?(user, memberTypeIds)
      end

      def self.textoParticipanteTipo2Default(memberTypeIds)
        if (memberTypeIds.nil?) || (memberTypeIds.empty?) || (memberTypeIds.include? 1) then return ""; end

        lista = []

        for memberType in memberTypeIds do
            lista.append(MemberType.find(memberType)[:value])
        end
        return lista.to_s
      end

      def self.textoParticipanteTipo2DefaultSiNoCualquierCiudadano(memberTypeIds)
        if (memberTypeIds.nil?) || (memberTypeIds.empty?) || (memberTypeIds.include? 1) then return nil; end
        return textoParticipanteTipo2Default(memberTypeIds)
      end

      def self.textoParticipanteTipo2(user, memberTypeIds)
        if MemberType.can_vote?(user, memberTypeIds)
          return nil
        else
          return MemberType.textoParticipanteTipo2Default(memberTypeIds)
        end
      end

      def self.textoParticipanteTipo2WithPrefix(user, memberTypeIds, prefix)
        mensajeAlert=MemberType.textoParticipanteTipo2(user, memberTypeIds)

        if not mensajeAlert.nil?
          mensajeAlert=prefix+" "+mensajeAlert
        end
        return mensajeAlert
      end
end
