import { Widget, useTracking } from '@strapi/admin/strapi-admin';
import { Box, IconButton, Table, Tbody, Td, Tr, Typography } from '@strapi/design-system';
import { Pencil } from '@strapi/icons';
import { useIntl } from 'react-intl';
import { Link, useNavigate } from 'react-router-dom';
import { styled } from 'styled-components';

import { DocumentStatus } from '../pages/EditView/components/DocumentStatus';
import { useGetRecentDocumentsQuery } from '../services/homepage';

import { RelativeTime } from './RelativeTime';

import type { RecentDocument } from '../../../shared/contracts/homepage';

const CellTypography = styled(Typography).attrs({ maxWidth: '14.4rem', display: 'block' })`
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
`;

const RecentDocumentsTable = ({ documents }: { documents: RecentDocument[] }) => {
  const { formatMessage } = useIntl();
  const { trackUsage } = useTracking();
  const navigate = useNavigate();

  const getEditViewLink = (document: RecentDocument): string => {
    const isSingleType = document.kind === 'singleType';
    const kindPath = isSingleType ? 'single-types' : 'collection-types';
    const queryParams = document.locale ? `?plugins[i18n][locale]=${document.locale}` : '';

    return `/content-manager/${kindPath}/${document.contentTypeUid}${isSingleType ? '' : '/' + document.documentId}${queryParams}`;
  };

  const handleRowClick = (document: RecentDocument) => () => {
    trackUsage('willEditEntryFromHome');
    const link = getEditViewLink(document);
    navigate(link);
  };

  return (
    <Table colCount={5} rowCount={documents?.length ?? 0}>
      <Tbody>
        {documents?.map((document) => (
          <Tr onClick={handleRowClick(document)} cursor="pointer" key={document.documentId}>
            <Td>
              <CellTypography title={document.title} variant="omega" textColor="neutral800">
                {document.title}
              </CellTypography>
            </Td>
            <Td>
              <CellTypography variant="omega" textColor="neutral600">
                {document.kind === 'singleType'
                  ? formatMessage({
                      id: 'content-manager.widget.last-edited.single-type',
                      defaultMessage: 'Single-Type',
                    })
                  : formatMessage({
                      id: document.contentTypeDisplayName,
                      defaultMessage: document.contentTypeDisplayName,
                    })}
              </CellTypography>
            </Td>
            <Td>
              <Box display="inline-block">
                {document.status ? (
                  <DocumentStatus status={document.status} />
                ) : (
                  <Typography textColor="neutral600" aria-hidden>
                    -
                  </Typography>
                )}
              </Box>
            </Td>
            <Td>
              <Typography textColor="neutral600">
                <RelativeTime timestamp={new Date(document.updatedAt)} />
              </Typography>
            </Td>
            <Td onClick={(e) => e.stopPropagation()}>
              <Box display="inline-block">
                <IconButton
                  tag={Link}
                  to={getEditViewLink(document)}
                  onClick={() => trackUsage('willEditEntryFromHome')}
                  label={formatMessage({
                    id: 'content-manager.actions.edit.label',
                    defaultMessage: 'Edit',
                  })}
                  variant="ghost"
                >
                  <Pencil />
                </IconButton>
              </Box>
            </Td>
          </Tr>
        ))}
      </Tbody>
    </Table>
  );
};

/* -------------------------------------------------------------------------------------------------
 * LastEditedWidget
 * -----------------------------------------------------------------------------------------------*/

const LastEditedWidget = () => {
  const { formatMessage } = useIntl();
  const { data, isLoading, error } = useGetRecentDocumentsQuery({ action: 'update' });

  if (isLoading) {
    return <Widget.Loading />;
  }

  if (error || !data) {
    return <Widget.Error />;
  }

  if (data.length === 0) {
    return (
      <Widget.NoData>
        {formatMessage({
          id: 'content-manager.widget.last-edited.no-data',
          defaultMessage: 'No edited entries',
        })}
      </Widget.NoData>
    );
  }

  return <RecentDocumentsTable documents={data} />;
};

/* -------------------------------------------------------------------------------------------------
 * LastPublishedWidget
 * -----------------------------------------------------------------------------------------------*/

const LastPublishedWidget = () => {
  const { formatMessage } = useIntl();
  const { data, isLoading, error } = useGetRecentDocumentsQuery({ action: 'publish' });

  if (isLoading) {
    return <Widget.Loading />;
  }

  if (error || !data) {
    return <Widget.Error />;
  }

  if (data.length === 0) {
    return (
      <Widget.NoData>
        {formatMessage({
          id: 'content-manager.widget.last-published.no-data',
          defaultMessage: 'No published entries',
        })}
      </Widget.NoData>
    );
  }

  return <RecentDocumentsTable documents={data} />;
};

export { LastEditedWidget, LastPublishedWidget };
